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

        static let tempChartViewTop: CGFloat = 54

        static let tempChartViewBottom: CGFloat = 30

        static let chartViewHeight: CGFloat = 288

        static let chartViewXOffset: CGFloat = 16

        static let chartSelectViewHeight: CGFloat = 43

        static let popupAnimationInterval: TimeInterval = 0.25

        static let chartIndex: Int = 0
    }

    private var charts = [Chart]()

    private var chartView: MainChartView!

    private var tapGestureRecognizer: UITapGestureRecognizer!

    private var chartSelectViewController: ChartSelectViewController!

    private var pointPopupViewController: PointPopupViewController!

    private let linearFunctionFactory = LinearFunctionFactory<CGFloat>()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupData()
	}

	private func setupUI() {
        view.backgroundColor = .white
        setupChartView()
        setupChartSelectViewController()
        setupPointPopupViewController()
        setupTapGestureRecognizer()
	}

    private func setupChartView() {
        chartView = MainChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = .white
        view.addSubview(chartView)
    }

    private func setupChartSelectViewController() {
        chartSelectViewController = ChartSelectViewController()
        chartSelectViewController.delegate = self
        addChild(chartSelectViewController)
        chartSelectViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartSelectViewController.view)
        chartSelectViewController.didMove(toParent: self)
    }

    private func setupPointPopupViewController() {
        pointPopupViewController = PointPopupViewController()
        addChild(pointPopupViewController)
        pointPopupViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pointPopupViewController.view.isHidden = true
        view.addSubview(pointPopupViewController.view)
        pointPopupViewController.didMove(toParent: self)
    }

    private func setupTapGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        chartView.addGestureRecognizer(tapGestureRecognizer)
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
        let lines = charts[Constants.chartIndex].lines.sorted { $0.name < $1.name }
        chartView.dataLines = lines
        chartSelectViewController.dataLines = lines
        pointPopupViewController.dataLines = lines
//        chartView.dataLines = [DataLine.mockDataLine1]
//        chartSelectViewController.dataLines = [DataLine.mockDataLine1]
	}

    @objc
    private func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else {
            return
        }

        guard pointPopupViewController.view.isHidden else {
            pointPopupViewController.view.isHidden = true
            return
        }

        let tapPoint = gestureRecognizer.location(in: chartView)

        let dataRect = DataRect(
                origin: DataPoint(x: chartView.xRange.lowerBound, y: chartView.yRange.lowerBound),
                width: chartView.xRange.upperBound - chartView.xRange.lowerBound,
                height: chartView.yRange.upperBound - chartView.yRange.lowerBound)

        pointPopupViewController.setupWith(tapPoint: tapPoint, visibleDataRect: dataRect, chartRect: chartView.bounds)
        let size = pointPopupViewController.view.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: chartView.frame.height))
        let tapPointInSelf = self.view.convert(tapPoint, from: chartView)
        pointPopupViewController.view.frame = CGRect(center: CGPoint(x: tapPointInSelf.x, y: chartView.center.y), size: size)
        pointPopupViewController.view.isHidden = false
    }

    override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		chartView.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: view.safeAreaInsets.top + Constants.tempChartViewTop,
                width: view.frame.width - 2 * Constants.chartViewXOffset,
                height: Constants.chartViewHeight)

        chartSelectViewController.view.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: chartView.frame.maxY + Constants.tempChartViewBottom,
                width: view.frame.width - 2 * Constants.chartViewXOffset,
                height: Constants.chartSelectViewHeight)

        //TODO: reset popupVC's frame
	}
}

// MARK: -

extension ChartViewController: ChartSelectViewControllerDelegate {

    func didSelectChartPartition(minUnitX: DataPoint.DataType, maxUnitX: DataPoint.DataType) {
/*
        let croppedDataLines: [DataLine] = chartSelectViewController.dataLines.map {
            let pointsInRange = $0.points.filter { $0.x >= minUnitX && $0.x <= maxUnitX }
            return DataLine(points: pointsInRange, color: $0.color, name: $0.name)
        }
        chartView.dataLines = croppedDataLines
*/

        chartView.xRange = minUnitX...maxUnitX
        pointPopupViewController.view.isHidden = true
    }
}
