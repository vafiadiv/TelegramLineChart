//
//  ChartSelectView.swift
//  ArtFit
//
//  Created by Valentin Vafiadi on 2019-05-15.
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartSelectView: UIView {

    // MARK: - Public properties

    var dataLines = [DataLine]() {
        didSet {
            chartView.dataLines = dataLines
        }
    }

    // MARK: - Private properties

    private var chartView: ChartView!
    private var selectionWindow: ChartSelectWindowView!

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
        setupChartView()
        setupSelectionWindow()
//        setupGestureRecognizer()
    }

    private func setupChartView() {
        chartView = ChartView()
        addSubview(chartView)
    }

    private func setupSelectionWindow() {
        selectionWindow = ChartSelectWindowView()
        addSubview(selectionWindow)
    }

    // MARK: - Public methods

    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = self.bounds
        selectionWindow.frame = self.bounds
    }
}
