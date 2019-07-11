//
//  ChartDateIndicatorViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import UIKit

class ChartDateIndicatorViewController: UIViewController, RootViewProtocol {

    typealias RootViewType = ChartDateIndicatorView


    var totalXRange: ClosedRange<DataPoint.DataType> = 0...0

    var visibleXRange: ClosedRange<DataPoint.DataType> = 0...0 {
        didSet {
            rootView.visibleXRange = visibleXRange
        }
    }

    // MARK: - Overrides

    override func loadView() {
        view = ChartDateIndicatorView()
    }
}
