//
//  LineRangeSelectionViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class LineRangeSelectionViewController: UIViewController, RootViewProtocol {

    typealias RootViewType = LineRangeSelectionView

    // MARK: - Public properties

    weak var delegate: LineRangeSelectionViewControllerDelegate?

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
        let lineRangeSelectionView = LineRangeSelectionView()
        lineRangeSelectionView.delegate = self
        self.view = lineRangeSelectionView
    }
}

// MARK: -

extension LineRangeSelectionViewController: LineRangeSelectionViewDelegate {

    func selectedRangeDidChange() {

        let xRange = dataLines.xRange

        let totalUnitWidth = xRange.upperBound - xRange.lowerBound

        let minUnitXSelected = xRange.lowerBound + DataPoint.DataType(CGFloat(totalUnitWidth) * rootView.selectedRelativeRange.lowerBound)
        let maxUnitXSelected = xRange.lowerBound + DataPoint.DataType(CGFloat(totalUnitWidth) * rootView.selectedRelativeRange.upperBound)

        delegate?.didSelectChartPartition(minUnitX: minUnitXSelected, maxUnitX: maxUnitXSelected)
    }
}
