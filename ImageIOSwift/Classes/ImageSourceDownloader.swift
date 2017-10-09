//
//  ImageSourceDownloader.swift
//  ImageIOSwift
//
//  Created by David Beck on 10/9/17.
//

import Foundation


public class ImageSourceDownloader: NSObject {
	public private(set) var session: URLSession!
	
	private let queue = DispatchQueue(label: "ImageSourceDownloader")
	
	public static let shared = ImageSourceDownloader()
	
	public init(configuration: URLSessionConfiguration = .default) {
		super.init()
		
		let delegateQueue = OperationQueue()
		delegateQueue.underlyingQueue = queue
		
		session = URLSession(configuration: configuration, delegate: self, delegateQueue: delegateQueue)
	}
	
	
	// MARK: - Downloading
	
	public class Task {
		public let sessionTask: URLSessionTask
		public let imageSource: ImageSource
		
		fileprivate var data: Data = Data() {
			didSet {
				imageSource.update(data, isFinal: false)
			}
		}
		
		fileprivate var completionHandlers: [(Data?, URLResponse?, Error?) -> Void] = []
		
		init(sessionTask: URLSessionTask, imageSource: ImageSource) {
			self.sessionTask = sessionTask
			self.imageSource = imageSource
		}
		
		fileprivate func complete(with error: Error?) {
			imageSource.update(data, isFinal: true)
			
			for handler in completionHandlers {
				handler(data, sessionTask.response, error)
			}
		}
	}
	
	var tasks: [URLRequest:Task] = [:]
	
	public func download(_ url: URL, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> Task {
		let request = URLRequest(url: url)
		return self.download(request, completionHandler: completionHandler)
	}
	
	public func download(_ request: URLRequest, completionHandler: ((Data?, URLResponse?, Error?) -> Void)? = nil) -> Task {
		return queue.sync() {
			let task: Task
			if let existing = tasks[request] {
				task = existing
			} else {
				let imageSource = ImageSource.incremental()
				
				let sessionTask = session.dataTask(with: request)
				sessionTask.resume()
				
				task = Task(sessionTask: sessionTask, imageSource: imageSource)
				tasks[request] = task
			}
			
			if let completionHandler = completionHandler {
				task.completionHandlers.append(completionHandler)
			}
			
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
