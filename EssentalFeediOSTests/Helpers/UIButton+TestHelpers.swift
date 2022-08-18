//
//  UIButton+TestHelpers.swift
//  EssentalFeediOSTests
//
//  Created by Austin Betzer on 8/17/22.
//

import UIKit

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
