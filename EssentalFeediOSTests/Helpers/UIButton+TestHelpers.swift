//
//  UIButton+TestHelpers.swift
//  EssentalFeediOSTests
//
//  Created by Austin Betzer on 8/17/22.
//

import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
