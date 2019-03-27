//
//  ViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi on 17/03/2019.
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {

	private var chartView: ChartView!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
		self.setupData()
	}


	private func setupUI() {
		self.chartView = ChartView()
		self.chartView.backgroundColor = .white
		self.view.addSubview(self.chartView)
	}

	private func setupData() {
		guard let data = ChartLoader.loadChartData() else {
			return
		}

		guard let charts = try? ChartJSONParser.charts(from: data) else {
			//TODO: error
			return
		}

		let mockPoints = [
			DataPoint(x: 0, y: 0),
			DataPoint(x: 5, y: 10),
			DataPoint(x: 10, y: 5),
			DataPoint(x: 15, y: 15),
			DataPoint(x: 20, y: 15),
		]
		let dataLine = DataLine(points: mockPoints, color: .green, name: "Line")
//		self.chartView.dataLine = dataLine
		let croppedLines = charts[0].lines.map { line in
			return DataLine(points: Array(line.points[0...9]), color: line.color, name: line.name)
		}
		self.chartView.dataLines = croppedLines
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
//		self.chartView.frame = self.view.bounds.insetBy(dx: 50, dy: 50)
		self.chartView.frame = self.view.bounds
	}
}
