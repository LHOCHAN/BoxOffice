//
//  BOMovieProtocol.swift
//  BoxOffice
//
//  Created by 최영준 on 11/12/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import UIKit

// MARK: - BOMovie Protocol
// MARK: -
protocol BOMovie: BOMovieRequest, BOMovieOrderReqesut, BOMovieUI { }

protocol BOMovieRequest {
    var requestAPI: RequestAPI { get }
    /// 네트워크 호출에서 에러 발생시 처리. 내부에서 alert이 호출된다.
    func errorHandler(_ error: Error?, completionHandler: (() -> Void)?)
}

extension BOMovieRequest {
    var requestAPI: RequestAPI {
        return RequestAPI.shared
    }
}

protocol BOMovieOrderReqesut {
    /// 정렬 타입에 따른 노티피케이션을 등록한다.
    func registerOrderTypeNotification()
    /// 노티피케이션 처리한다.
    func didReceiveNotification(_ notification: Notification)
}

@objc protocol BOMovieUI {
    /// 등급에 따라 이미지를 변경한다.
    @objc optional func setGradeImageView(_ imageView: UIImageView, grade: Int)
    /// 인디케이터 동작.
    @objc optional func indicatorViewAnimating(_ indicatorView: UIActivityIndicatorView, isStart: Bool)
    /// 인디케이터 동작.
    @objc optional func indicatorViewAnimating(_ indicatorView: UIActivityIndicatorView, refresher: UIRefreshControl, isStart: Bool)
    /// 정렬 타입을 선택하는 액션시트를 나타낸다.
    @objc optional func setOrderType()
}

extension BOMovieUI {
    func setGradeImageView(_ imageView: UIImageView, grade: Int) {
        if grade == 0 {
            imageView.image = UIImage(named: "ic_allages")
        } else if grade == 12 {
            imageView.image = UIImage(named: "ic_12")
        } else if grade == 15 {
            imageView.image = UIImage(named: "ic_15")
        } else {
            imageView.image = UIImage(named: "ic_19")
        }
    }
}

// MARK: - BOMovieViewController
// MARK: -
class BOMovieViewController: UIViewController, BOMovie {
    // MARK: - BOMovieRequest protocol
    // MARK: -
    func errorHandler(_ error: Error? = nil, completionHandler: (() -> Void)? = nil) {
        let message: String
        if let error = error {
            message = "네트워크 오류: \(error.localizedDescription)"
        } else {
            message = "네트워크 오류가 발생하였습니다."
        }
        // alert 메서드에 main thread 동작이 구현되어 있음.
        alert(message) {
            completionHandler?()
        }
    }
    
    // MARK: - BOMovieMainRequest protocol
    // MARK: -
    func registerOrderTypeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveNotification(_:)), name: .changeOrderType, object: nil)
    }
    @objc func didReceiveNotification(_ notification: Notification) {
        guard let orderType = notification.userInfo?["orderType"] as? OrderType else {
            return
        }
        RequestAPI.orderType = orderType
        /*
         재정의 하여 사용한다
         */
    }
    
    // MARK: - BOMovieUI protocol
    // MARK: -
    func indicatorViewAnimating(_ indicatorView: UIActivityIndicatorView, isStart: Bool) {
        if isStart {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view.bringSubviewToFront(indicatorView)
                indicatorView.isHidden = false
                indicatorView.startAnimating()
            }
        } else {
            DispatchQueue.main.async {
                indicatorView.stopAnimating()
                indicatorView.isHidden = true
            }
        }
    }
    func indicatorViewAnimating(_ indicatorView: UIActivityIndicatorView, refresher: UIRefreshControl, isStart: Bool) {
        if isStart {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.view.bringSubviewToFront(indicatorView)
                indicatorView.isHidden = false
                indicatorView.startAnimating()
            }
        } else {
            DispatchQueue.main.async {
                indicatorView.stopAnimating()
                indicatorView.isHidden = true
                if refresher.isRefreshing {
                    refresher.perform(#selector(refresher.endRefreshing), with: nil, afterDelay: 0.00)
                }
            }
        }
    }
    @objc func setOrderType() {
        // 메인 스레드에서 실행되도록
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let actionSheet = UIAlertController(title: "정렬방식 선택", message: "어떤 순서로 정렬할까요?", preferredStyle: .actionSheet)
            let reservationRateAction = UIAlertAction(title: "예매율", style: .default) { (_) in
                NotificationCenter.default.post(name: .changeOrderType, object: nil, userInfo: ["orderType": OrderType.reservationRate])
            }
            let currationAction = UIAlertAction(title: "큐레이션", style: .default) { (_) in
                NotificationCenter.default.post(name: .changeOrderType, object: nil, userInfo: ["orderType": OrderType.curation])
            }
            let dateAction = UIAlertAction(title: "개봉일", style: .default) { (_) in
                NotificationCenter.default.post(name: .changeOrderType, object: nil, userInfo: ["orderType": OrderType.date])
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel)
            actionSheet.addAction(reservationRateAction)
            actionSheet.addAction(currationAction)
            actionSheet.addAction(dateAction)
            actionSheet.addAction(cancelAction)
            self.present(actionSheet, animated: true)
        }
    }
}
