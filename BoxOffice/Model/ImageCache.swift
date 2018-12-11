//
//  ImageCache.swift
//  BoxOffice
//
//  Created by 최영준 on 10/12/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import UIKit

class ImageCache {
    // MARK: - Properties
    // MARK: -
    private let memoryCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager()
    private var diskCachePath: URL?
    private lazy var filePaths = [URL]()
    private let diskCacheQueue: DispatchQueue
    
    // MARK: - Initializer
    // MARK: -
    init(name: String, countLimit: Int = 20) {
        diskCacheQueue = DispatchQueue(label: "0junchoi.BoxOffice.ImageCahce.diskCacheQueue.\(name)", qos: .background)
        memoryCache.name = name
        memoryCache.countLimit = countLimit
        if let path = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            diskCachePath = path.appendingPathComponent(name)
        }
    }
    
    // MARK: - Public methods
    // MARK: -
    /// UIImage를 key와 함께 메모리 캐시에 저장한다. 선택적으로 디스크 캐시에도 저장할 수 있다.
    func store(_ image: UIImage, forKey key: String, onDisk: Bool = false) {
        let newKey = key.createKey()
        memoryCache.setObject(image, forKey: newKey as NSString)
        if onDisk, let diskCachePath = diskCachePath {
            diskCacheQueue.async { [weak self] in
                guard let self = self else { return }
                if !self.fileManager.fileExists(atPath: diskCachePath.path) {
                    do {
                        try self.fileManager.createDirectory(atPath: diskCachePath.path, withIntermediateDirectories: true, attributes: nil)
                    } catch let error {
                        print(error)
                    }
                }
                let filePath = diskCachePath.appendingPathComponent(newKey)
                self.filePaths.append(filePath)
                self.fileManager.createFile(atPath: filePath.path, contents: image.pngData(), attributes: nil)
            }
        }
    }
    /// 메모리와 디스크에서 제거한다.
    func remove(forKey key: String, inMemory: Bool = true, onDisk: Bool = false) {
        let newKey = key.createKey()
        if inMemory {
            memoryCache.removeObject(forKey: newKey as NSString)
        }
        if onDisk, let diskCachePath = diskCachePath {
            diskCacheQueue.async { [weak self] in
                guard let self = self else { return }
                do {
                    let filePath = diskCachePath.appendingPathComponent(newKey)
                    try self.fileManager.removeItem(atPath: filePath.path)
                    if let index = self.filePaths.firstIndex(of: filePath) {
                        self.filePaths.remove(at: index)
                    }
                } catch let error {
                    print(error)
                }
            }
        }
    }
    /// 캐시를 비운다.
    func clearCache() {
        memoryCache.removeAllObjects()
        diskCacheQueue.async { [weak self] in
            guard let self = self else { return }
            for filePath in self.filePaths {
                do {
                    try self.fileManager.removeItem(atPath: filePath.path)
                } catch let error {
                    print(error)
                }
            }
        }
    }
    /// 메모리에서 키 값에 해당하는 이미지를 검색하여 반환한다.
    func retrieve(forKey key: String) -> UIImage? {
        let newKey = key.createKey()
        if let image = memoryCache.object(forKey: newKey as NSString) {
            return image
        } else if let diskCachePath = diskCachePath {
            let filePath = diskCachePath.appendingPathComponent(newKey)
            if let image = UIImage(contentsOfFile: filePath.path) {
                return image
            }
        }
        return nil
    }
}
