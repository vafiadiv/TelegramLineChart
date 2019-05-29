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
        static let chartIndex: Int = 1
    }

    private var charts = [Chart]()

    private var chartView: MainChartView!

    private var tapGestureRecognizer: UITapGestureRecognizer!

    private var chartSelectViewController: ChartSelectViewController!

    private let linearFunctionFactory = LinearFunctionFactory<CGFloat>()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupData()
	}

	private func setupUI() {
        setupChartView()
        setupChartSelectView()
        setupTapGestureRecognizer()
	}

    private func setupChartView() {
        chartView = MainChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        (chartView.layer as? ChartLayer)?.debugDrawing = true
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
		chartView.dataLines = charts[Constants.chartIndex].lines
        chartSelectViewController.dataLines = chartView.dataLines
//        chartView.dataLines = [DataLine.mockDataLine1]
//        chartSelectViewController.dataLines = [DataLine.mockDataLine1]
	}

    @objc
    private func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else {
            return
        }

        let highlightedPoint = gestureRecognizer.location(in: chartView)
//        chartView.highlightedPoint = highlightedPoint

        let unitMinX = CGFloat(chartView.xRange.lowerBound)
        let unitMaxX = CGFloat(chartView.xRange.upperBound)
//        let unitMinY = CGFloat(chartView.yRange.lowerBound)
//        let unitMaxY = CGFloat(chartView.yRange.upperBound)

        let dataRect = DataRect(
                origin: DataPoint(x: chartView.xRange.lowerBound, y: chartView.xRange.lowerBound),
                width: chartView.xRange.upperBound - chartView.xRange.lowerBound,
                height: chartView.yRange.upperBound - chartView.yRange.lowerBound)
/*
        let tapUnitPoint = DataPoint(
                x: DataPoint.DataType(unitMinX + (unitMaxX - unitMinX) * highlightedPoint.x / chartView.frame.width),
                y: DataPoint.DataType(unitMinY + (unitMaxY - unitMinY) * highlightedPoint.y / chartView.frame.height))
*/
        let tapPointUnitX = DataPoint.DataType(unitMinX + (unitMaxX - unitMinX) * highlightedPoint.x / chartView.frame.width)

        if chartView.highlightedPointsInfos != nil {
            chartView.highlightedPointsInfos = nil
        } else {
            let popupPointInfos: [ChartPopupPointInfo] = chartView.dataLines.compactMap { dataLine in
                guard let leftPointUnit = dataLine.points.last(where: { $0.x < tapPointUnitX }),
                      let rightPointUnit = dataLine.points.first(where: { $0.x > tapPointUnitX }) else {
                    return nil
                }

                let leftPoint = leftPointUnit.convert(from: dataRect, to: chartView.frame)
                let rightPoint = rightPointUnit.convert(from: dataRect, to: chartView.frame)
                let function = linearFunctionFactory.function(x1: leftPoint.x, y1: leftPoint.y, x2: rightPoint.x, y2: rightPoint.y)

                let tapIntersection = CGPoint(x: highlightedPoint.x, y: function(highlightedPoint.x))

                print("line \(dataLine.name): leftPoint = \(leftPointUnit), rightPoint = \(rightPointUnit)")
                return ChartPopupPointInfo(point: tapIntersection, color: dataLine.color, value: -999)
            }

            chartView.highlightedPointsInfos = popupPointInfos
/*
            chartView.highlightedPointsInfos = [
                ChartPopupPointInfo(point: CGPoint(x: 100, y: 100), color: .red, value: 111),
                ChartPopupPointInfo(point: CGPoint(x: 200, y: 200), color: .green, value: 222),
                ChartPopupPointInfo(point: CGPoint(x: 300, y: 300), color: .blue, value: 333),
            ]
*/
        }
    }

    override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		chartView.frame = CGRect(
                x: 0,
                y: view.safeAreaInsets.top,
                width: view.frame.width,
                height: view.frame.height - view.safeAreaInsets.top - Constants.chartSelectViewHeight)

        chartSelectViewController.view.frame = CGRect(
                x: 0,
                y: view.frame.height - Constants.chartSelectViewHeight,
                width: view.frame.width,
                height: Constants.chartSelectViewHeight)
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
    }
}
