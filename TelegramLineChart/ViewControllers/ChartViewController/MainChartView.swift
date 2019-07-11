//
//  MainChartView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import UIKit

class MainChartView: UIView  {

    // MARK: - Public properties

    var dataLines = [DataLine]() {
        didSet {
            chartLayer.dataLines = dataLines
        }
    }

    var xRange: ClosedRange<DataPoint.DataType> = 0...0 {
        didSet {
            chartLayer.xRange = xRange
        }
    }

    var yRange: ClosedRange<DataPoint.DataType> {
        return chartLayer.yRange
    }

    func setDataLineHidden(_ isHidden: Bool, at index: Int, animated: Bool = true) {
        chartLayer.setDataLineHidden(isHidden, at: index, animated: animated)
    }

    var drawHorizontalLines: Bool = true {
        didSet {
            chartLayer.drawHorizontalLines = drawHorizontalLines
        }
    }

    var lineWidth: CGFloat = 1.0 {
        didSet {
            chartLayer.lineWidth = lineWidth
        }
    }

    // MARK: - Private properties

    override class var layerClass: AnyClass {
        return ChartLayer.self
    }

    private var chartLayer: ChartLayer {
        guard let chartLayer = layer as? ChartLayer else {
            fatalError("Wrong layer class")
        }
        return chartLayer
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Private methods

    private func setupUI() {
        setupChartLayer()
        backgroundColor = .white
    }

    private func setupChartLayer() {
        chartLayer.backgroundColor = UIColor.selectionChartBackground.cgColor
        chartLayer.drawHorizontalLines = true
        chartLayer.contentsScale = UIScreen.main.scale
    }
}
