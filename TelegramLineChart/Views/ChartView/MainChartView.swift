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

    var xRange: ClosedRange<DataPoint.XType> = 0...0 {
        didSet {
            chartLayer.xRange = xRange
        }
    }

    var yRange: ClosedRange<DataPoint.YType> {
        return chartLayer.yRange
    }

    var highlightedPoint: CGPoint? {
        didSet {
            chartLayer.highlightedPoint = highlightedPoint
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
//        setupTapGestureRecognizer()
    }

    private func setupChartLayer() {
        chartLayer.lineWidth = 1
        chartLayer.backgroundColor = UIColor.selectionChartBackground.cgColor
        chartLayer.drawHorizontalLines = true
        chartLayer.contentsScale = UIScreen.main.scale
    }

/*
    private func setupTapGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc
    private func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else {
            return
        }

        chartLayer.highlightedPoint = gestureRecognizer.location(in: self)
    }
*/
}
