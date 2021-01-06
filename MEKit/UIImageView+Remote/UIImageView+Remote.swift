//
//  RemoteImageView.swift
//  RandomUserInc
//
//  Created by Pablo Ezequiel Romero Giovannoni on 23/11/2019.
//  Copyright © 2019 Pablo Ezequiel Romero Giovannoni. All rights reserved.
//

import UIKit

private struct AssociatedKeys {
    static var ImageURL = "ImageURL"
}

public struct RemoteImageViewConfiguration {
    private init() { }
    static var defaultImage: UIImage?
    static var downloadService: DownloadServiceProtocol = DownloadService()
}

extension UIImageView {
    typealias CompletionClosure = ((URL?, Error?) -> Void)
    static let spinnerTag = 999
    
    fileprivate var spinner: UIActivityIndicatorView? {
        return viewWithTag(Self.spinnerTag) as? UIActivityIndicatorView
    }
    
    fileprivate var imageURL: URL? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.ImageURL) as? URL
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.ImageURL, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setImageURL(_ url: URL?) {
        guard hasToRefreshContent(for: url) else { return }
        cleanCurrentConfiguration()
       
        guard let url = url else { return }
        imageURL = url
    
        guard let image = cachedImage(for: url) else {
            loadImage(from: url)
            return
        }
        
        self.image = image
    }
    
    private func loadImage(from url: URL) {
        presentLoadingMode()
        let localUrl = localCachedImageUrl(for: url)
                 
        RemoteImageViewConfiguration.downloadService.downloadContent(fromURL: url, to: localUrl) { (remoteUrl: URL, localUrl: URL, error: Error?) in
            self.removeLoadingMode()
            if error != nil {
                self.presentErrorMode()
            } else {
                if let currentUrl = self.imageURL, currentUrl == url {
//                    print("downloaded \(url) to \(localUrl)")
                    self.image = self.cachedImage(for: url)
                }
            }
        }
    }
    
    private func hasToRefreshContent(for newUrl: URL?) -> Bool {
        if image == nil {
            return true
        } else {
            if let currentURL = imageURL {
                return currentURL != newUrl
            } else {
                return true
            }
        }
    }
    
    // MARK: - Cache
    
    private func cachedImage(for remoteUrl: URL) -> UIImage? {
        let localUrl = localCachedImageUrl(for: remoteUrl)
        if FileSystemHelper.existFile(at: localUrl) {
            let path = localUrl.path
            return UIImage(contentsOfFile: path)
        } else {
            return nil
        }
    }
    
    private func localCachedImageUrl(for remoteUrl: URL) -> URL {
        var localURL = FileSystemHelper.cachesUrl()
        localURL.appendPathComponent(remoteUrl.sha256Hash())
        return localURL
    }
    
    // MARK: - States
    
    private func cleanCurrentConfiguration() {
        imageURL = nil
        image = nil
        removeLoadingMode()
    }
    
    private func presentLoadingMode() {
        if let defualtImage = RemoteImageViewConfiguration.defaultImage {
            image = defualtImage
        } else if spinner == nil {
            image = nil
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.tag = Self.spinnerTag
            addSubview(spinner)
            
            spinner.startAnimating()
            spinner.center = CGPoint(x: bounds.size.width / 2.0,
                                     y: bounds.size.height / 2.0)
            
            spinner.autoresizingMask = [.flexibleBottomMargin,
                                        .flexibleLeftMargin,
                                        .flexibleRightMargin,
                                        .flexibleTopMargin]
        }
    }
    
    private func removeLoadingMode() {
        spinner?.removeFromSuperview()
    }
    
    private func presentErrorMode() {
        image = nil
        removeLoadingMode()
    }
    
}
