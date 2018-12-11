//
//  ExtensionUIViewController.swift
//  BoxOffice
//
//  Created by 최영준 on 10/12/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import UIKit

extension UIViewController {
    /// 얼럿 컨트롤러 간편 메서드
    func alert(_ message: String, completionHandler: (() -> Void)? = nil) {
        // 메인 스레드에서 실행되도록
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
                completionHandler?() // completionHandler 매개변수의 값이 nil이 아닐 때에만 실행되도록
            }
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
}
