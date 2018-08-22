//
//  Array+Extension.swift
//  AdvancedNavigationController Example
//
//  Created by Gero Embser on 22.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
