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
	
	public typealias CompletionHandler = (ImageSource, Data?, URLResponse?, Error?) -> Void
	
	/// A central request for a particular url.
	///
	/// While Task tracks a single request, multiple requests for the same url will be uniqued so that they aren't requested multiple times. When a task is cancelled, it gets removed from the download task, and only when all subtasks have been cancelled is the actual download request cancelled.
	fileprivate class DownloadTask: NSObject {
		/// The lock queue from the parent downloader.
		let queue: DispatchQueue
		
		/// The underlying task used to download the file.
		let sessionTask: URLSessionTask
		
		/// The image source that is being loaded incrementally.
		///
		/// The image source is created immediately when the download begins. You can display this immediately, and metadata like size, as well as the actual image, will be loaded as the data becomes available.
		private(set) lazy var imageSource: ImageSource = .incremental()
		
		/// The image data that has been loaded so far.
		var data: Data = Data() {
			didSet {
				if #available(iOS 10.0, macOS 10.12, *) {
					dispatchPrecondition(condition: .onQueue(queue))
				}
				
				imageSource.update(data, isFinal: false)
			}
		}
		
		var error: Swift.Error?
		
		/// The underlying request tasks.
		fileprivate var tasks: [Weak<Task>] = []
		
		init(sessionTask: URLSessionTask, queue: DispatchQueue) {
			self.sessionTask = sessionTask
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
			self.error = error ?? imageSource.error
			
			sendComplete()
		}
		
		fileprivate func sendComplete() {
			for task in tasks {
				task.value?.sendCompletion(data: data, response: sessionTask.response, error: error)
			}
			tasks = []
		}
		
		/// Cancel an individual sub task, and the download if there are no more sub tasks.
		///
		/// - Parameter task: The task to cancel.
		fileprivate func cancel(_ task: Task) {
			queue.async {
				guard let index = self.tasks.firstIndex(where: { $0.value === task }) else { return }
				self.tasks.remove(at: index)
				
				let error = CocoaError(.userCancelled)
				task.sendCompletion(data: nil, response: nil, error: error)
				
				if self.tasks.isEmpty {
					self.sessionTask.cancel()
				}
			}
		}
		
		fileprivate func resume(_ task: Task) {
			guard !tasks.contains(where: { $0.value === task }) else { return }
			
			if error != nil || imageSource.status == .complete {
				task.sendCompletion(data: data, response: sessionTask.response, error: error)
			} else {
				self.tasks.append(Weak(task))
				
				sessionTask.resume()
			}
		}
	}
	
	/// The state for a given image source download request.
	///
	/// Each request for an image source will create a new task that can be used to track the progress of the download and cancel it if needed.
	/// Multiple tasks may share the same image source and url session task, and can be canclled independently.
	public class Task {
		fileprivate var downloadTask: DownloadTask
		
		/// The underlying task used to download the file.
		///
		/// You should not cancel the session task directly because other requests may be sharing it. Instead, use `cancel()` which will cancel the session task if there are not other requests using it.
		public var sessionTask: URLSessionTask {
			return downloadTask.sessionTask
		}
		
		/// The image source that is being loaded incrementally.
		///
		/// The image source is created immediately when the download begins. You can display this immediately, and metadata like size, as well as the actual image, will be loaded as the data becomes available.
		public var imageSource: ImageSource {
			return downloadTask.imageSource
		}
		
		private var completionHandler: CompletionHandler?
		
		fileprivate init(downloadTask: DownloadTask, completionHandler: CompletionHandler?) {
			self.downloadTask = downloadTask
			self.completionHandler = completionHandler
		}
		
		/// Cancels the request.
		///
		/// If there are no other requests currently waiting on the session task, it will be cancelled as well. The completion handler will be called immediately with a cancel error.
		/// If there are multiple tasks downloading the same image, this may not cancel the session task.
		public func cancel() {
			downloadTask.cancel(self)
		}
		
		/// Starts the task.
		///
		/// Even if the image has already been downloaded by another task (in which case the imageSource will already be completely available),
		/// the completion handler will not be called until this method is called.
		public func resume() {
			downloadTask.resume(self)
		}
		
		fileprivate func sendCompletion(data: Data?, response: URLResponse?, error: Error?) {
			guard let completionHandler = self.completionHandler else { return }
			
			self.completionHandler = nil // only send once
			completionHandler(imageSource, data, response, error)
		}
	}
	
	/// Current tasks being downloaded.
	///
	/// When a task is completed, it is removed from this list. This list is used to lookup tasks and update them from the url session delegate methods as well as share downloads.
	fileprivate var tasks: [URLRequest:DownloadTask] = [:]
	
	/// Successfully completed tasks.
	fileprivate let taskCache = ReferenceCache<URLRequest,DownloadTask>()
	
	/// Download an image from a given url.
	///
	/// Multiple requests for the same resource will use the same download and image source to avoid requesting data multiple times and using extra memory.
	///
	/// The image source is available immediately from the returned Task.
	///
	/// - Parameters:
	///   - url: The remote URL to download from.
	///   - completionHandler: Called when the download completes.
	/// - Returns: A task for the request. You can use the task's image source immediately to display an incrementally loaded image.
	public func download(_ url: URL, completionHandler: CompletionHandler? = nil) -> Task {
		let request = URLRequest(url: url)
		return self.download(request, completionHandler: completionHandler)
	}
	
	/// Download a remote image.
	///
	/// Multiple requests for the same resource will use the same download and image source to avoid requesting data multiple times and using extra memory.
	///
	/// The image source is available immediately from the returned Task.
	///
	/// - Parameters:
	///   - request: The request used to download the image.
	///   - completionHandler: Called when the download completes.
	/// - Returns: A task for the request. You can use the task's image source immediately to display an incrementally loaded image.
	public func download(_ request: URLRequest, completionHandler: CompletionHandler? = nil) -> Task {
		let task = self.task(for: request)
		task.resume()
		return task
	}
	
	/// Task to download an image.
	///
	/// Multiple requests for the same resource will use the same download and image source to avoid requesting data multiple times and using extra memory.
	///
	/// The image source is available immediately from the returned Task. It will not start downloading until you call `resume()`.
	///
	/// - Parameters:
	///   - url: The remote URL to download from.
	///   - completionHandler: Called when the download completes.
	/// - Returns: A task for the request. You can use the task's image source immediately to display an incrementally loaded image.
	public func task(for url: URL, completionHandler: CompletionHandler? = nil) -> Task {
		let request = URLRequest(url: url)
		return self.task(for: request, completionHandler: completionHandler)
	}
	
	/// Task to download an image.
	///
	/// Multiple requests for the same resource will use the same download and image source to avoid requesting data multiple times and using extra memory.
	///
	/// The image source is available immediately from the returned Task. It will not start downloading until you call `resume()`.
	///
	/// - Parameters:
	///   - url: The remote URL to download from.
	///   - completionHandler: Called when the download completes.
	/// - Returns: A task for the request. You can use the task's image source immediately to display an incrementally loaded image.
	public func task(for request: URLRequest, completionHandler: CompletionHandler? = nil) -> Task {
		let downloadTask = self.downloadTask(for: request)
		let task = Task(downloadTask: downloadTask, completionHandler: completionHandler)
		return task
	}
	
	/// Get an underlying download task.
	///
	/// This will get either an in progress task, a previously succesful task, or create a new one.
	private func downloadTask(for request: URLRequest) -> DownloadTask {
		if let inProgress = tasks[request] {
			return inProgress
		} else if let cached = taskCache[request] {
			return cached
		} else {
			let sessionTask = session.dataTask(with: request)
			
			let downloadTask = DownloadTask(sessionTask: sessionTask, queue: self.queue)
			tasks[request] = downloadTask
			return downloadTask
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
			let downloadTask = tasks[request]
		else { return }
		
		tasks[request] = nil
		downloadTask.complete(with: error)
		
		if downloadTask.error == nil {
			taskCache[request] = downloadTask
		}
	}
}
