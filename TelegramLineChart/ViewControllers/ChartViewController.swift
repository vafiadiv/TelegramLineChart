//
//  ViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi on 17/03/2019.
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {

    private enum Constants {
        static let chartSelectViewHeight: CGFloat = 50
    }

	private var chartView: ChartView!
	private var chartSelectView: ChartSelectView!

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupData()
	}


	private func setupUI() {
        setupChartView()
        setupChartSelectView()
	}

    private func setupChartView() {
        chartView = ChartView()
        chartView.backgroundColor = .white
        view.addSubview(chartView)
    }

    private func setupChartSelectView() {
        chartSelectView = ChartSelectView()
        view.addSubview(chartSelectView)
    }


	private func setupData() {
		guard let data = ChartLoader.loadChartData() else {
			return
		}

		guard let charts = try? ChartJSONParser.charts(from: data) else {
			//TODO: error
			return
		}

		let croppedLines = charts[0].lines.map { line in
			return DataLine(points: Array(line.points[0...9]), color: line.color, name: line.name)
		}
		chartView.dataLines = croppedLines
        chartSelectView.dataLines = croppedLines
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		chartView.frame = CGRect(width: view.frame.width, height: view.frame.height - Constants.chartSelectViewHeight)
        chartSelectView.frame = CGRect(
                x: 0,
                y: view.frame.height - Constants.chartSelectViewHeight,
                width: view.frame.width,
                height: Constants.chartSelectViewHeight)
	}
}
