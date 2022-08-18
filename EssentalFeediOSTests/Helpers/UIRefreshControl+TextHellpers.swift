//
//  UIRefreshControl+TextHellpers.swift
//  EssentalFeediOSTests
//
//  Created by Austin Betzer on 8/17/22.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
