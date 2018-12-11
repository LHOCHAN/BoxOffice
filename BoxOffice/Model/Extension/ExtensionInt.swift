//
//  ExtensionInt.swift
//  BoxOffice
//
//  Created by 최영준 on 10/12/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import Foundation

extension Int {
    /// Int 타입 변수를 문자열로 변환하고 천단위로 ','를 삽입한다.
    func toStringWithComma() -> String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        if let str = numberFormatter.string(from: NSNumber(integerLiteral: self)) {
            return str
        }
        return nil
    }
}
