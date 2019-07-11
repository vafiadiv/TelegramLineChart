//
//  UIViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import UIKit

protocol RootViewProtocol {
    associatedtype RootViewType: UIView

    var rootView: RootViewType { get }
}

extension RootViewProtocol where Self: UIViewController {

    var rootView: RootViewType {
        guard let rootView = self.view as? RootViewType else {
            fatalError("""
                       \(type(of: self)) contains wrong root view type: expected \(RootViewType.description()), 
                       found \(self.view.description)
                       """)
        }

        return rootView
    }
}
