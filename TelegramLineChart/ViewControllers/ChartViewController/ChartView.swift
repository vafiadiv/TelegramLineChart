//
//  ChartView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartView: UIView {

    private enum Constants {

        static let tempChartViewTop: CGFloat = 54

        static let dateIndicatorViewHeight: CGFloat = 29

        static let chartViewHeight: CGFloat = 288

        static let chartViewSizeRatio: CGFloat = 343.0 / 288.0

        static let chartViewXOffset: CGFloat = 16

        static let lineRangeSelectionViewHeight: CGFloat = 43

        static let popupAnimationInterval: TimeInterval = 0.25
    }

    // MARK: - Public properties

    private(set) var chartView: MainChartView

    private(set) var lineRangeSelectionView: LineRangeSelectionView

    private(set) var pointPopupView: PointPopupView

    private(set) var chartDateIndicatorView: ChartDateIndicatorView

    private(set) var lineSelectionView: LineSelectionView

    // MARK: - Initialization

    init(lineRangeSelectionView: LineRangeSelectionView,
         pointPopupView: PointPopupView,
         chartDateIndicatorView: ChartDateIndicatorView,
         lineSelectionView: LineSelectionView) {

        self.chartView = MainChartView()
        self.chartView.lineWidth = 2.0

        self.lineRangeSelectionView = lineRangeSelectionView
        self.pointPopupView = pointPopupView
        self.chartDateIndicatorView = chartDateIndicatorView
        self.lineSelectionView = lineSelectionView
        super.init(frame: .zero)

        let subviews = [chartView,
                        lineRangeSelectionView,
                        pointPopupView,
                        chartDateIndicatorView,
                        lineSelectionView]

        subviews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Public methods

    static func height(for width: CGFloat, numberOfLines: Int) -> CGFloat {
        let widthWithOffset = width - 2 * Constants.chartViewXOffset

        let chartViewHeight = widthWithOffset / Constants.chartViewSizeRatio

        let lineSelectionHeight = LineSelectionView.height(for: numberOfLines)

        return chartViewHeight +
                Constants.dateIndicatorViewHeight +
                Constants.lineRangeSelectionViewHeight +
                lineSelectionHeight
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()

        let widthWithOffset = bounds.width - 2 * Constants.chartViewXOffset

        chartView.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: 0,
                width: widthWithOffset,
                height: Constants.chartViewHeight)

        chartDateIndicatorView.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: chartView.frame.maxY,
                width: widthWithOffset,
                height: Constants.dateIndicatorViewHeight)

        lineRangeSelectionView.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: chartView.frame.maxY + Constants.dateIndicatorViewHeight,
                width: widthWithOffset,
                height: Constants.lineRangeSelectionViewHeight)

        let maxHeightSize = CGSize(width: bounds.width, height: .greatestFiniteMagnitude)

        lineSelectionView.frame = CGRect(
                x: 0,
                y: lineRangeSelectionView.frame.maxY,
                width: bounds.width,
                height: lineSelectionView.sizeThatFits(maxHeightSize).height)
    }

}
