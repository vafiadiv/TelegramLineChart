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

        static let chartIndex: Int = 1
    }

    private var charts = [Chart]()

    private var chartView: MainChartView!

    private var tapGestureRecognizer: UITapGestureRecognizer!

    private var chartSelectViewController: ChartSelectViewController!

    private var pointPopupViewController: PointPopupViewController!

    private var chartDateIndicatorViewController: ChartDateIndicatorViewController!

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
        setupDateIndicatorViewController()
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

    private func setupDateIndicatorViewController() {
        chartDateIndicatorViewController = ChartDateIndicatorViewController()
        addChild(chartDateIndicatorViewController)
        chartDateIndicatorViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chartDateIndicatorViewController.view)
        chartDateIndicatorViewController.view.backgroundColor = .white
        chartDateIndicatorViewController.didMove(toParent: self)
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
//        let lines = [DataLine.mockDataLine2]
        chartView.dataLines = lines
        chartSelectViewController.dataLines = lines
        pointPopupViewController.dataLines = lines
        chartDateIndicatorViewController.totalXRange = lines.xRange
//        chartView.dataLines = [DataLine.mockDataLine1]
//        chartSelectViewController.dataLines = [DataLine.mockDataLine1]
	}

    @objc
    private func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else {
            return
        }

        guard pointPopupViewController.view.isHidden else {
            pointPopupViewController.view.setIsHiddenAnimated(true)
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
        pointPopupViewController.view.setIsHiddenAnimated(false)
    }

    override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

        let widthWithOffset = view.frame.width - 2 * Constants.chartViewXOffset

		chartView.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: view.safeAreaInsets.top + Constants.tempChartViewTop,
                width: widthWithOffset,
                height: Constants.chartViewHeight)

        chartDateIndicatorViewController.view.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: chartView.frame.maxY,
                width: widthWithOffset,
                height: Constants.tempChartViewBottom)

        chartSelectViewController.view.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: chartView.frame.maxY + Constants.tempChartViewBottom,
                width: widthWithOffset,
                height: Constants.chartSelectViewHeight)

        //TODO: reset popupVC's frame
	}
}

// MARK: -

extension ChartViewController: ChartSelectViewControllerDelegate {

    func didSelectChartPartition(minUnitX: DataPoint.DataType, maxUnitX: DataPoint.DataType) {

        let range = minUnitX...maxUnitX

        chartView.xRange = range

        if !pointPopupViewController.view.isHidden {
            pointPopupViewController.view.setIsHiddenAnimated(true)
        }

//        chartDateIndicatorViewController.visibleXRange = (minUnitX / 1_000_000)...(maxUnitX / 1_000_000)
        chartDateIndicatorViewController.visibleXRange = range
    }
}
