//
//  ChartSelectViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartSelectViewController: UIViewController, RootViewProtocol {

    typealias RootViewType = ChartSelectView

    // MARK: - Public properties

    weak var delegate: ChartSelectViewControllerDelegate?

    var dataLines = [DataLine]() {
        didSet {
            rootView.dataLines = dataLines

            rootView.graphXRange = dataLines.xRange

            selectedRangeDidChange()
        }
    }

    // MARK: - Public methods

    func setDataLineHidden(_ isHidden: Bool, at index: Int, animated: Bool = true) {
        rootView.setDataLineHidden(isHidden, at: index, animated: animated)
    }

    // MARK: - Private methods

    override func loadView() {
        let chartSelectView = ChartSelectView()
        chartSelectView.delegate = self
        self.view = chartSelectView
    }
}

// MARK: -

extension ChartSelectViewController: ChartSelectViewDelegate {

    func selectedRangeDidChange() {

        let xRange = dataLines.xRange

        let totalUnitWidth = xRange.upperBound - xRange.lowerBound

        let minUnitXSelected = xRange.lowerBound + DataPoint.DataType(CGFloat(totalUnitWidth) * rootView.selectedRelativeRange.lowerBound)
        let maxUnitXSelected = xRange.lowerBound + DataPoint.DataType(CGFloat(totalUnitWidth) * rootView.selectedRelativeRange.upperBound)

        delegate?.didSelectChartPartition(minUnitX: minUnitXSelected, maxUnitX: maxUnitXSelected)
    }
}
