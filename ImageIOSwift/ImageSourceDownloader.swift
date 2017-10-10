//
//  ImageSourceDownloader.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/9/17.
//

import Foundation


/// A controller that manages downloading image sources incrementally.
public class ImageSourceDownloader: NSObject {
	/// The underlying session used to download image data.
	public private(set) var session: URLSession!
	
	/// The lock queue to protect access to task state.
	private let queue = DispatchQueue(label: "ImageSourceDownloader")
	
	/// A default instance to use to download images.
	public static let shared = ImageSourceDownloader()
	
	/// Create a customized downloader.
	///
	/// - Parameter configuration: The configuration to use with the URLSession.
	public init(configuration: URLSessionConfiguration = .default) {
		super.init()
		
		let delegateQueue = OperationQueue()
		delegateQueue.underlyingQueue = queue
		
		session = URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
	}
	
	
	// MARK: - Downloading
	
	/// A central request for a particular url.
	///
	/// While Task tracks a single request, multiple requests for the same url will be uniqued so that they aren't requested multiple times. When a task is cancelled, it gets removed from the download task, and only when all subtasks have been cancelled is the actual download request cancelled.
	fileprivate class DownloadTask {
		/// The lock queue from the parent downloader.
		let queue: DispatchQueue
		
		/// The underlying task used to download the file.
		let sessionTask: URLSessionTask
		
		/// The image source that is being loaded incrementally.
		///
		/// The image source is created immediately when the download begins. You can display this immediately, and metadata like size, as well as the actual image, will be loaded as the data becomes available.
		let imageSource: ImageSource
		
		/// The image data that has been loaded so far.
		var data: Data = Data() {
			didSet {
				if #available(iOS 10.0, macOS 10.12, *) {
					dispatchPrecondition(condition: .onQueue(queue))
				}
				
				imageSource.update(data, isFinal: false)
			}
		}
		
		/// The underlying request tasks.
		fileprivate var tasks: [Task] = []
		
		init(sessionTask: URLSessionTask, imageSource: ImageSource, queue: DispatchQueue) {
			self.sessionTask = sessionTask
			self.imageSource = imageSource
			self.queue = queue
		}
		
		/// Finalize the image source and notify any requesters.
		///
		/// - Parameter error: An error, or nil if the request was successful.
		fileprivate func complete(with error: Error?) {
			if #available(iOS 10.0, macOS 10.12, *) {
				dispatchPrecondition(condition: .onQueue(queue))
			}
			
			imageSource.update(data, isFinal: true)
			
			for task in tasks {
				task.completionHandler?(data, sessionTask.response, error)
			}
		}
		
		/// Cancel an individual sub task, and the download if there are no more sub tasks.
		///
		/// - Parameter task: The task to cancel.
		fileprivate func cancel(_ task: Task) {
			queue.async {
				guard let index = self.tasks.index(where: { $0 === task }) else { return }
				self.tasks.remove(at: index)
				
				let error = CocoaError(.userCancelled)
				task.completionHandler?(nil, nil, error)
				
				if self.tasks.isEmpty {
					self.sessionTask.cancel()
				}
			}
		}
	}
	
	/// The state for a given image source download request.
	///
	/// Each request for an image source will create a new task that can be used to track the progress of the download and cancel it if needed.
	public class Task {
		fileprivate weak var downloadTask: DownloadTask?
		
		/// The underlying task used to download the file.
		///
		/// You should not cancel the session task directly because other requests may be sharing it. Instead, use `cancel()` which will cancel the session task if there are not other requests using it.
		public let sessionTask: URLSessionTask
		
		/// The image source that is being loaded incrementally.
		///
		/// The image source is created immediately when the download begins. You can display this immediately, and metadata like size, as well as the actual image, will be loaded as the data becomes available.
		public let imageSource: ImageSource
		
		fileprivate var completionHandler: ((Data?, URLResponse?, Error?) -> Void)?
		
		fileprivate init(downloadTask: DownloadTask, completionHandler: ((Data?, URLResponse?, Error?) -> Void)?) {
			self.downloadTask = downloadTask
			// keep a strong reference in case downloadTask goes away
			self.sessionTask = downloadTask.sessionTask
			self.imageSource = downloadTask.imageSource
			
			self.completionHandler = completionHandler
		}
		
		/// Cancels the request.
		///
		/// If there are no other requests currently waiting on the session task, it will be cancelled as well. The completion handler will be called immediately with a cancel error.
		public func cancel() {
			downloadTask?.cancel(self)
		}
	}
	
	/// Current tasks being downloaded.
	///
	/// When a task is completed, it is removed from this list. This list is used to lookup tasks and update them from the url session delegate methods as well as share downloads.
	fileprivate var tasks: [URLRequest:DownloadTask] = [:]
	
	/// Download an image from a given url.
	///
	/// Multiple requests for the same resource will use the same download to avoid requesting data multiple times. Repeated requests use the URLSession's cache.
	///
	/// The image source is available immediately from the returned Task.
	///
	/// - Parameters:
	///   - url: The remote URL to download from.
	///   - completionHandler: Called when the download completes.
	/// - Returns: A task for the request. You can use the task's image source immediately to display an incrementally loaded image.
	public func download(_ url: URL, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> Task {
		let request = URLRequest(url: url)
		return self.download(request, completionHandler: completionHandler)
	}
	
	/// Download a remote image.
	///
	/// Multiple requests for the same resource will use the same download to avoid requesting data multiple times. Repeated requests use the URLSession's cache.
	///
	/// The image source is available immediately from the returned Task.
	///
	/// - Parameters:
	///   - request: The request used to download the image.
	///   - completionHandler: Called when the download completes.
	/// - Returns: A task for the request. You can use the task's image source immediately to display an incrementally loaded image.
	public func download(_ request: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> Task {
		return queue.sync() {
			let downloadTask: DownloadTask
			if let existing = tasks[request] {
				downloadTask = existing
			} else {
				let imageSource = ImageSource.incremental()
				
				let sessionTask = session.dataTask(with: request)
				sessionTask.resume()
				
				downloadTask = DownloadTask(sessionTask: sessionTask, imageSource: imageSource, queue: self.queue)
				tasks[request] = downloadTask
			}
			
			let task = Task(downloadTask: downloadTask, completionHandler: completionHandler)
			downloadTask.tasks.append(task)
			
			return task
		}
	}
}


extension ImageSourceDownloader: URLSessionDataDelegate {
	public func urlSession(_ session: URLSession, dataTask sessionTask: URLSessionDataTask, didReceive data: Data) {
		guard
			let request = sessionTask.originalRequest,
			let task = tasks[request]
		else { return }
		
		task.data.append(data)
	}
	
	public func urlSession(_ session: URLSession, task sessionTask: URLSessionTask, didCompleteWithError error: Error?) {
		guard
			let request = sessionTask.originalRequest,
			let task = tasks[request]
		else { return }
		
		tasks[request] = nil
		task.complete(with: error)
	}
}
