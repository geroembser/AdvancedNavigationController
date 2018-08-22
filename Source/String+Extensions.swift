//
//  String+Extensions.swift
//  AdvancedNavigationController iOS
//
//  Created by Gero Embser on 21.08.18.
//  Copyright © 2018 Gero Embser. All rights reserved.
//

import Foundation

extension String {
    ///Condenses all whitespaces
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: .whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}
