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
        }
    }

    // MARK: - Private methods

    override func loadView() {
        let chartSelectView = ChartSelectView()
        chartSelectView.delegate = self
        self.view = chartSelectView
    }
}

extension ChartSelectViewController: ChartSelectViewDelegate {
    func selectionWindowFrameDidChange() {
        let totalViewWidth = self.rootView.frame.width
        let minSelectionViewX = self.rootView.selectionWindowView.frame.minX
        let maxSelectionViewX = self.rootView.selectionWindowView.frame.maxX

        let minSelectedXRelative = minSelectionViewX / totalViewWidth
        let maxSelectedXRelative = maxSelectionViewX / totalViewWidth

        let firstPoints = dataLines.compactMap { $0.points.first?.x } //TODO: remove copypaste with chart view
        let lastPoints = dataLines.compactMap { $0.points.last?.x }

        let minUnitX = firstPoints.min() ?? 0
        let maxUnitX = lastPoints.max() ?? minUnitX

        let totalUnitWidth = maxUnitX - minUnitX

        let minUnitXSelected = minUnitX + DataPoint.XType(CGFloat(totalUnitWidth) * minSelectedXRelative)
        let maxUnitXSelected = minUnitX + DataPoint.XType(CGFloat(totalUnitWidth) * maxSelectedXRelative)

        delegate?.didSelectChartPartition(minUnitX: minUnitXSelected, maxUnitX: maxUnitXSelected)
    }
}
