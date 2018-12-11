//
//  ExtensionString.swift
//  BoxOffice
//
//  Created by 최영준 on 10/12/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import Foundation

extension String {
    /// 문자열에서 공백을 지운다.
    func trim() -> String {
        return self.replacingOccurrences(of: " ", with: "")
    }
    /// 이미지 캐시에서 사용할 키 생성.
    func createKey() -> String {
        return replacingOccurrences(of: "/", with: "")
    }
}
