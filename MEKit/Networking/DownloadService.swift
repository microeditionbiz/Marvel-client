//
//  DownloadService.swift
//  MEKit
//
//  Created by Pablo Ezequiel Romero Giovannoni on 30/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import Foundation

typealias DownloadServiceCompletion = (_ url: URL,_ localURL: URL,_ error: Error?)->()
  
protocol DownloadOperationProtocol {
    var fromURL: URL {get}
    func cancel()
}

protocol DownloadServiceProtocol {
    @discardableResult
    func downloadContent(fromURL: URL, to localURL: URL, completion: @escaping DownloadServiceCompletion) -> DownloadOperationProtocol
}

class DowloadService: DownloadServiceProtocol {
    fileprivate let operationQueue: OperationQueue
    
    init() {
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = 3
    }
    
    @discardableResult
    func downloadContent(fromURL: URL, to localURL: URL, completion: @escaping DownloadServiceCompletion) -> DownloadOperationProtocol {
        let op = DownloadOperation(fromURL: fromURL, to: localURL, completion: completion)
        operationQueue.addOperation(op)
        return op
    }
}

class DownloadOperation: AsyncOperation, DownloadOperationProtocol {
    let fromURL: URL
    fileprivate let localURL: URL
    fileprivate let completion: DownloadServiceCompletion
    fileprivate var downloadTask: URLSessionDownloadTask!
    
    init(fromURL: URL, to localURL: URL, completion: @escaping DownloadServiceCompletion) {
        self.fromURL = fromURL
        self.localURL = localURL
        self.completion = completion
    }
    
    override func main() {
        self.downloadTask = URLSession.shared.downloadTask(with: fromURL) { downloadedURL, response, downloadError in
            var completionError: Error?
        
            if let downloadError = downloadError {
                completionError = downloadError
            } else {
                do {
                    try FileSystemHelper.copyFile(at: downloadedURL!, to: self.localURL)
                } catch {
                    completionError = error
                }
            }
            
            DispatchQueue.main.async {
                self.completion(self.fromURL, self.localURL, completionError)
                self.finish()
            }
        }
    
        downloadTask.resume()
    }
    
    override func cancel() {
        downloadTask.cancel()
        super.cancel()
    }
}
