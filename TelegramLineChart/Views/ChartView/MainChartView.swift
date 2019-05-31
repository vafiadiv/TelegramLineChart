//
//  MainChartView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
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

    private var popupLayer: ChartPopupLayer!

    private var tapGestureRecognizer: UITapGestureRecognizer!

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Private methods

    private func setupUI() {
        setupChartLayer()
        setupPopupLayer()
    }

    private func setupChartLayer() {
        chartLayer.backgroundColor = UIColor.selectionChartBackground.cgColor
        chartLayer.drawHorizontalLines = true
        chartLayer.contentsScale = UIScreen.main.scale
    }

    private func setupPopupLayer() {
        popupLayer = ChartPopupLayer()
        popupLayer.contentsScale = UIScreen.main.scale
        chartLayer.addSublayer(popupLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        popupLayer.frame = chartLayer.bounds
    }
}