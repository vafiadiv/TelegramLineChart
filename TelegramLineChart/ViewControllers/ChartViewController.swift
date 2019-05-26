//
//  ViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi on 17/03/2019.
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController, RootViewProtocol {

    typealias RootViewType = ChartSelectView

    private enum Constants {
        static let chartSelectViewHeight: CGFloat = 50
        static let chartIndex: Int = 1
    }

    private var charts = [Chart]()
	private var chartView: ChartView!

	private var chartSelectViewController: ChartSelectViewController!

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
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = .white
        view.addSubview(chartView)
    }

    private func setupChartSelectView() {
        chartSelectViewController = ChartSelectViewController()
        chartSelectViewController.delegate = self
        addChild(chartSelectViewController)
        chartSelectViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartSelectViewController.view)
        chartSelectViewController.didMove(toParent: self)
    }

	private func setupData() {
		guard let data = ChartLoader.loadChartData() else {
			return
		}

		guard let charts = try? ChartJSONParser.charts(from: data) else {
			//TODO: error
			return
		}

        self.charts = charts

/*
		let croppedLines = charts[0].lines.map { line in
			return DataLine(points: Array(line.points[0...9]), color: line.color, name: line.name)
		}

		chartView.dataLines = croppedLines
*/
		chartView.dataLines = charts[Constants.chartIndex].lines
        chartSelectViewController.dataLines = charts[Constants.chartIndex].lines
//        chartView.dataLines = [DataLine.mockDataLine1]
//        chartSelectViewController.dataLines = [DataLine.mockDataLine1]
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		chartView.frame = CGRect(width: view.frame.width, height: view.frame.height - Constants.chartSelectViewHeight)

        chartSelectViewController.view.frame = CGRect(
                x: 0,
                y: view.frame.height - Constants.chartSelectViewHeight,
                width: view.frame.width,
                height: Constants.chartSelectViewHeight)
	}
}

extension ChartViewController: ChartSelectViewControllerDelegate {

    func didSelectChartPartition(minUnitX: DataPoint.XType, maxUnitX: DataPoint.XType) {
/*
        let croppedDataLines: [DataLine] = chartSelectViewController.dataLines.map {
            let pointsInRange = $0.points.filter { $0.x >= minUnitX && $0.x <= maxUnitX }
            return DataLine(points: pointsInRange, color: $0.color, name: $0.name)
        }
        chartView.dataLines = croppedDataLines
*/

        chartView.xRange = minUnitX...maxUnitX
    }
}
