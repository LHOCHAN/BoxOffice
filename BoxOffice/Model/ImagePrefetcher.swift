//
//  ImagePrefetcher.swift
//  BoxOffice
//
//  Created by 최영준 on 10/12/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import UIKit

class ImagePrefetcher {
    // MARK: - Properties
    // MARK: -
    private let imageCache: ImageCache
    private lazy var requestAPI = RequestAPI.shared
    
    // MARK: - Initializer
    // MARK: -
    init(imageCache: ImageCache) {
        self.imageCache = imageCache
    }
    
    // MARK: - Public methods
    // MARK: -
    /// 이미지 프리페칭을 시작한다.
    func startPrefetching(url: URL, completionHandler: ((UIImage?) -> Void)? = nil) {
        let key = url.absoluteString
        if let image = imageCache.retrieve(forKey: key) {
            completionHandler?(image)
        } else {
            requestAPI.downloadMovieImage(url) { [weak self] (isSuccess, data, error) in
                guard let self = self else { return }
                if isSuccess, let image = data as? UIImage {
                    self.imageCache.store(image, forKey: key, onDisk: true)
                    completionHandler?(image)
                } else if let error = error {
                    print(error)
                }
            }
        }
    }
    /// 이미지 프리페칭을 취소한다.
    func cancelPrefetching(url: URL) {
        requestAPI.cancelDownloadingImage(url)
    }
}
