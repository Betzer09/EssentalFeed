//
//  UIRefreshControl+TextHellpers.swift
//  EssentalFeediOSTests
//
//  Created by Austin Betzer on 8/17/22.
//

import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
