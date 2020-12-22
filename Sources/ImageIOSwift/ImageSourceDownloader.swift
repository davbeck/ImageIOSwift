import Foundation
#if canImport(UIKit)
	import UIKit
#endif

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
		delegateQueue.underlyingQueue = self.queue
		
		self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
		
		#if canImport(UIKit)
			NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
		#endif
	}
	
	// MARK: - Downloading
	
	public typealias CompletionHandler = (ImageSource, Data?, URLResponse?, Error?) -> Void
	
	/// A central request for a particular url.
	///
	/// While Task tracks a single request, multiple requests for the same url will be uniqued so that they aren't requested multiple times. When a task is cancelled, it gets removed from the download task, and only when all subtasks have been cancelled is the actual download request cancelled.
	fileprivate class DownloadTask {
		/// The lock queue from the parent downloader.
		let queue: DispatchQueue
		
		/// The underlying task used to download the file.
		let sessionTask: URLSessionTask
		
		fileprivate lazy var _imageSource: ImageSource = .incremental()
		
		/// The image source that is being loaded incrementally.
		///
		/// The image source is created immediately when the download begins. You can display this immediately, and metadata like size, as well as the actual image, will be loaded as the data becomes available.
		var imageSource: ImageSource {
			if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
				dispatchPrecondition(condition: .notOnQueue(queue))
			}
			
			// because the property is lazy, it will be written to on the first read
			return self.queue.sync { self._imageSource }
		}
		
		/// The image data that has been loaded so far.
		var data: Data = Data() {
			didSet {
				if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
					dispatchPrecondition(condition: .onQueue(queue))
				}
				
				self._imageSource.update(self.data, isFinal: false)
			}
		}
		
		var error: Swift.Error?
		
		/// The underlying request tasks.
		fileprivate var tasks: [UUID: Weak<Task>] = [:]
		
		init(sessionTask: URLSessionTask, queue: DispatchQueue) {
			self.sessionTask = sessionTask
			self.queue = queue
		}
		
		/// Finalize the image source and notify any requesters.
		///
		/// - Parameter error: An error, or nil if the request was successful.
		fileprivate func complete(with error: Error?) {
			if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
				dispatchPrecondition(condition: .onQueue(queue))
			}
			
			self._imageSource.update(self.data, isFinal: true)
			self.error = error ?? self._imageSource.error
			
			self.sendComplete()
		}
		
		fileprivate func sendComplete() {
			for task in self.tasks.values {
				task.value?.sendCompletion(data: self.data, response: self.sessionTask.response, error: self.error)
			}
			self.tasks = [:]
		}
		
		/// Cancel an individual sub task, and the download if there are no more sub tasks.
		///
		/// - Parameter task: The task to cancel.
		fileprivate func cancel(taskID: UUID) {
			self.queue.async {
				if let task = self.tasks[taskID]?.value {
					let error = CocoaError(.userCancelled)
					task.sendCompletion(data: nil, response: nil, error: error)
				}
				self.tasks[taskID] = nil
				
				self.tasks = self.tasks.filter({ $0.1.value != nil })
				if self.tasks.isEmpty {
					self.sessionTask.cancel()
				}
			}
		}
		
		fileprivate func resume(_ task: Task) {
			self.queue.async {
				guard self.tasks[task.id]?.value == nil else { return }
				
				if self.error != nil || self._imageSource.status == .complete {
					task.sendCompletion(data: self.data, response: self.sessionTask.response, error: self.error)
				} else {
					self.tasks[task.id] = Weak(task)
					self.sessionTask.resume()
				}
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
			return self.downloadTask.sessionTask
		}
		
		/// The image source that is being loaded incrementally.
		///
		/// The image source is created immediately when the download begins. You can display this immediately, and metadata like size, as well as the actual image, will be loaded as the data becomes available.
		public var imageSource: ImageSource {
			return self.downloadTask.imageSource
		}
		
		private var completionHandler: CompletionHandler?
		
		private var completionQueue: DispatchQueue
		
		fileprivate let id = UUID()
		
		fileprivate init(downloadTask: DownloadTask, completionHandler: CompletionHandler?, completionQueue: DispatchQueue) {
			self.downloadTask = downloadTask
			self.completionHandler = completionHandler
			self.completionQueue = completionQueue
		}
		
		deinit {
			self.cancel()
		}
		
		/// Cancels the request.
		///
		/// If there are no other requests currently waiting on the session task, it will be cancelled as well. The completion handler will be called immediately with a cancel error.
		/// If there are multiple tasks downloading the same image, this may not cancel the session task.
		public func cancel() {
			self.downloadTask.cancel(taskID: self.id)
		}
		
		/// Starts the task.
		///
		/// Even if the image has already been downloaded by another task (in which case the imageSource will already be completely available),
		/// the completion handler will not be called until this method is called.
		public func resume() {
			self.downloadTask.resume(self)
		}
		
		fileprivate func sendCompletion(data: Data?, response: URLResponse?, error: Error?) {
			if #available(OSX 10.12, iOS 10.0, tvOS 10.0, watchOS 3.0, *) {
				dispatchPrecondition(condition: .onQueue(downloadTask.queue))
			}
			
			guard let completionHandler = self.completionHandler else { return }
			self.completionHandler = nil // only send once
			
			self.completionQueue.async {
				completionHandler(self.downloadTask._imageSource, data, response, error)
			}
		}
	}
	
	/// All active download tasks.
	///
	/// This will reference any tasks for this downloader until they are completely released, but will not itself retain the task. This allows us to always reuse existing tasks and not create duplicate image sources when the same resource is downloaded from multiple places.
	fileprivate var tasks: [URLRequest: Weak<DownloadTask>] = [:]
	
	/// Cache of download tasks.
	///
	/// Keeps tasks alive even if there isn't anything referencing them. This way if an image is requested again we can return the task immediately. Values aren't actually used, this is just to keep tasks alive so that they will be available in the tasks array.
	fileprivate var taskCache = [URLRequest: DownloadTask]()
	
	/// Download an image from a given url.
	///
	/// Multiple requests for the same resource will use the same download and image source to avoid requesting data multiple times and using extra memory.
	///
	/// The image source is available immediately from the returned Task.
	///
	/// - Parameters:
	///   - url: The remote URL to download from.
	///   - queue: The dispatch queue to call the completion handler on. Defaults to the main queue.
	///   - completionHandler: Called when the download completes.
	/// - Returns: A task for the request. You can use the task's image source immediately to display an incrementally loaded image.
	public func download(_ url: URL, queue: DispatchQueue = .main, completionHandler: CompletionHandler? = nil) -> Task {
		let request = URLRequest(url: url)
		return self.download(request, queue: queue, completionHandler: completionHandler)
	}
	
	/// Download a remote image.
	///
	/// Multiple requests for the same resource will use the same download and image source to avoid requesting data multiple times and using extra memory.
	///
	/// The image source is available immediately from the returned Task.
	///
	/// - Parameters:
	///   - request: The request used to download the image.
	///   - queue: The dispatch queue to call the completion handler on. Defaults to the main queue.
	///   - completionHandler: Called when the download completes.
	/// - Returns: A task for the request. You can use the task's image source immediately to display an incrementally loaded image.
	public func download(_ request: URLRequest, queue: DispatchQueue = .main, completionHandler: CompletionHandler? = nil) -> Task {
		let task = self.task(for: request, queue: queue, completionHandler: completionHandler)
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
	///   - queue: The dispatch queue to call the completion handler on. Defaults to the main queue.
	///   - completionHandler: Called when the download completes.
	/// - Returns: A task for the request. You can use the task's image source immediately to display an incrementally loaded image.
	public func task(for url: URL, queue: DispatchQueue = .main, completionHandler: CompletionHandler? = nil) -> Task {
		let request = URLRequest(url: url)
		return self.task(for: request, queue: queue, completionHandler: completionHandler)
	}
	
	/// Task to download an image.
	///
	/// Multiple requests for the same resource will use the same download and image source to avoid requesting data multiple times and using extra memory.
	///
	/// The image source is available immediately from the returned Task. It will not start downloading until you call `resume()`.
	///
	/// - Parameters:
	///   - request: The request used to download the image.
	///   - queue: The dispatch queue to call the completion handler on. Defaults to the main queue.
	///   - completionHandler: Called when the download completes.
	/// - Returns: A task for the request. You can use the task's image source immediately to display an incrementally loaded image.
	public func task(for request: URLRequest, queue: DispatchQueue = .main, completionHandler: CompletionHandler? = nil) -> Task {
		let downloadTask = self.downloadTask(for: request)
		let task = Task(downloadTask: downloadTask, completionHandler: completionHandler, completionQueue: queue)
		return task
	}
	
	/// Get an underlying download task.
	///
	/// This will get either an in progress task, a previously succesful task, or create a new one.
	private func downloadTask(for request: URLRequest) -> DownloadTask {
		return self.queue.sync {
			if let downloadTask = tasks[request]?.value {
				// in case our cache has been purged but the task was kept alive, extend that
				self.taskCache[request] = downloadTask
				return downloadTask
			} else {
				let sessionTask = self.session.dataTask(with: request)
				
				let downloadTask = DownloadTask(sessionTask: sessionTask, queue: self.queue)
				self.taskCache[request] = downloadTask
				self.tasks[request] = Weak(downloadTask)
				return downloadTask
			}
		}
	}
	
	// MARK: - Notifications
	
	@objc func didReceiveMemoryWarning(_: Notification) {
		// we may still have a reference to tasks in the tasks array if something else is keeping them alive
		// this just removes our hold on the task and allows them to be released if nothing else is referencing them
		self.taskCache.removeAll()
	}
}

extension ImageSourceDownloader: URLSessionDataDelegate {
	public func urlSession(_: URLSession, dataTask sessionTask: URLSessionDataTask, didReceive data: Data) {
		guard
			let request = sessionTask.originalRequest,
			let task = tasks[request]?.value
		else { return }
		
		task.data.append(data)
	}
	
	public func urlSession(_: URLSession, task sessionTask: URLSessionTask, didCompleteWithError error: Error?) {
		guard
			let request = sessionTask.originalRequest,
			let downloadTask = tasks[request]?.value
		else { return }
		
		self.tasks[request] = nil
		downloadTask.complete(with: error)
		
		if downloadTask.error == nil {
			self.taskCache[request] = downloadTask
		}
	}
}

extension ImageSourceDownloader.Task: CustomStringConvertible {
	public var description: String {
		return "ImageSourceDownloader.Task[\(ObjectIdentifier(self))](imageSource: \(imageSource))>"
	}
}
