//
//  ExtentionArray.swift
//  BoxOffice
//
//  Created by 최영준 on 10/12/2018.
//  Copyright © 2018 최영준. All rights reserved.
//

import Foundation

extension Array {
    /// 안전한 인덱스 접근.
    subscript(safeIndex index: Int) -> Element? {
        if indices.contains(index) {
            return self[index]
        }
        return nil
    }
}
