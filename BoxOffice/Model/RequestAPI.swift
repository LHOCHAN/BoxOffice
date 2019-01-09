//
//  RequestAPI.swift
//  BoxOffice
//
//  Created by 최영준 on 10/12/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import UIKit

/// 정렬 타입.
enum OrderType: Int {
    case reservationRate = 0    // 예매순
    case curation = 1           // 큐레이터
    case date = 2               // 개봉순
}

/// 완료 핸들러 타입 별칭. (Bool, [MovieData]) -> Void.
typealias completionHandler = (Bool, AnyObject?, Error?) -> Void
private var associationKey: UInt8 = 0

class RequestAPI {
    /// URL 타입.
    private enum URLType {
        case movies
        case movie
        case comments
        case post
    }
    
    // MARK: - Singleton
    // MARK: -
    static let shared = RequestAPI()
    private init() {}
    
    // MARK: - Properties
    // MARK: -
    static var orderType: OrderType? {
        get {
            return objc_getAssociatedObject(self, &associationKey) as? OrderType ?? OrderType.reservationRate
        } set {
            objc_setAssociatedObject(self, &associationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    private lazy var urlSession = URLSession.shared
    private var tasks = [URLSessionTask]()
    private let baseURL = "http://connect-boxoffice.run.goorm.io"
    
    // MARK: - Public methods
    // MARK: -
    /// 영화 목록 요청.
    func requestMovies(_ type: OrderType, completionHandler: @escaping completionHandler) {
        let parameter = ["order_type": "\(type.rawValue)"]
        guard let url = createURL(.movies, parameters: parameter) else {
            completionHandler(false, nil, nil)
            return
        }
        request(url, type: .movies, completionHandler: completionHandler)
    }
    /// 영화 상세정보 요청.
    func requestMovieDetailInfo(_ id: String, completionHandler: @escaping completionHandler) {
        let parameter = ["id": "\(id)"]
        guard let url = createURL(.movie, parameters: parameter) else {
            completionHandler(false, nil, nil)
            return
        }
        request(url, type: .movie, completionHandler: completionHandler)
    }
    /// 한줄평 목록 요청.
    func requestMovieComments(_ id: String, completionHandler: @escaping completionHandler) {
        let parameter = ["movie_id": "\(id)"]
        guard let url = createURL(.comments, parameters: parameter) else {
            completionHandler(false, nil, nil)
            return
        }
        request(url, type: .comments, completionHandler: completionHandler)
    }
    /// 영화 이미지 다운로드.
    func downloadMovieImage(_ url: URL, completionHandler: @escaping completionHandler) {
        guard tasks.firstIndex(where: { $0.originalRequest?.url == url }) == nil else {
            completionHandler(false, nil, nil)
            return
        }
        indicatorInMainQueue(visible: true)
        let task = urlSession.dataTask(with: url) { [weak self] (data, _, error) in
            guard let self = self else { return }
            self.indicatorInMainQueue(visible: false)
            if let error = error {
                completionHandler(false, nil, error)
            }
            guard let data = data, let image = UIImage(data: data) else {
                completionHandler(false, nil, nil)
                return
            }
            completionHandler(true, image, nil)
        }
        task.resume()
        tasks.append(task)
    }
    /// 이미지 다운로드 취소.
    func cancelDownloadingImage(_ url: URL) {
        guard let taskIndex = tasks.firstIndex(where: { $0.originalRequest?.url == url }),
            let task = tasks[safeIndex: taskIndex] else {
                return
        }
        indicatorInMainQueue(visible: false)
        task.cancel()
        tasks.remove(at: taskIndex)
    }
    /// 한줄평 등록 요청
    func postMovieComment(_ movieId: String, writer: String, contents: String, rating: Double, completion: @escaping completionHandler) {
        // 네트워크 인디케이터 활성화
        indicatorInMainQueue(visible: true)
        // 파라미터를 JSON 데이터로 디코딩하는 작업
        let time = Date().timeIntervalSince1970
        let comment = WriteCommentData(rating: rating, writer: writer, movieId: movieId, contents: contents, timestamp: Double(time))
        guard let uploadData = try? JSONEncoder().encode(comment),
            let url = createURL(.post, parameters: [:]) else {
                completion(false, nil, nil)
                return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 업로드 작업
        urlSession.uploadTask(with: request, from: uploadData) { [weak self] (data, response, error) in
            guard let self = self else { return }
            // 네트워크 인디케이터 비활성화
            self.indicatorInMainQueue(visible: false)
            if let error = error {
                completion(false, nil, error)
                return
            }
            // 상태코드가 2xx라면 성공, 아니면 실패
            if let  response = response as? HTTPURLResponse {
                if (200 ... 299).contains(response.statusCode) {
                    completion(true, nil, nil)
                } else {
                    let error = NSError(domain: "", code: response.statusCode, userInfo: [NSLocalizedDescriptionKey : "Server error"])
                    completion(false, nil, error)
                }
            }
        }.resume()
    }
    
    // MARK: - Private methods
    // MARK: -
    /// 요청 처리 메서드.
    private func request(_ url: URL, type: URLType, completionHandler: @escaping completionHandler) {
        indicatorInMainQueue(visible: true)
        urlSession.dataTask(with: url) { [weak self] (data, response, error) in
            guard let self = self else { return }
            self.indicatorInMainQueue(visible: false)
            if let error = error {
                completionHandler(false, nil, error)
                return
            }
            guard let data = data else {
                completionHandler(false, nil, nil)
                return
            }
            do {
                switch type {
                case .movies:
                    let apiResponse = try JSONDecoder().decode(APIResponseForMovies.self, from: data)
                    completionHandler(true, apiResponse.movies as AnyObject, nil)
                case .movie:
                    let apiResponse = try JSONDecoder().decode(MovieData.self, from: data)
                    completionHandler(true, apiResponse as AnyObject, nil)
                case .comments:
                    let apiResponse = try JSONDecoder().decode(APIResponseForComments.self, from: data)
                    completionHandler(true, apiResponse.comments as AnyObject, nil)
                default:
                    ()
                }
            } catch let error {
                completionHandler(false, nil, error)
            }
        }.resume()
    }
    /// URL 생성.
    private func createURL(_ type: URLType, parameters: [String: String]) -> URL? {
        var urlString = baseURL
        switch type {
        case .movies:
            urlString += "/movies?"
        case .movie:
            urlString += "/movie?"
        case .comments:
            urlString += "/comments?"
        case .post:
            urlString += "/comment"
            return URL(string: urlString)
        }
        let zippedParameters = zip(parameters.keys, parameters.keys.map { parameters[$0] })
        let parametersString = zippedParameters.map { "\($0)=\($1 ?? "")"}.joined(separator: "&")
        urlString += parametersString
        return URL(string: urlString)
    }
    /// 네트워크 인디케이터 로딩.
    private func indicatorInMainQueue(visible: Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = visible
        }
    }
}
