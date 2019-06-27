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

        static let chartIndex: Int = 2
    }

    // MARK: - Public properties

    var model: ChartViewControllerModel {
        didSet {
            updateModel(model: model)
        }
    }

    private func updateModel(model: ChartViewControllerModel) {
        chartView.dataLines = model.lines
        chartSelectViewController.dataLines = model.lines
        pointPopupViewController.dataLines = model.lines
        selectedXRange = model.selectedXRange
        setLineHiddenFlags(model.lineHiddenFlags, animated: false)
        chartDateIndicatorViewController.totalXRange = model.lines.xRange
    }

    // MARK: - Private properties

    private var selectedXRange: ClosedRange<DataPoint.DataType> {
        didSet {
            model.selectedXRange = selectedXRange

            chartView.xRange = selectedXRange

            if !pointPopupViewController.view.isHidden {
                pointPopupViewController.view.setIsHiddenAnimated(true)
            }
            chartDateIndicatorViewController.visibleXRange = selectedXRange
        }
    }

    private var lineHiddenFlags: [Bool] {
        didSet {
            setLineHiddenFlags(lineHiddenFlags, animated: false)
        }
    }

    private var chartView: MainChartView!

    private var tapGestureRecognizer: UITapGestureRecognizer!

    private var chartSelectViewController: ChartSelectViewController!

    private var pointPopupViewController: PointPopupViewController!

    private var chartDateIndicatorViewController: ChartDateIndicatorViewController!

    private let linearFunctionFactory = LinearFunctionFactory<CGFloat>()

    // MARK: - Initialization

    init(model: ChartViewControllerModel) {
        self.model = model
        self.selectedXRange = model.selectedXRange
        self.lineHiddenFlags = model.lineHiddenFlags
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
		setupData()
        updateModel(model: model)
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

    // MARK: - Private methods

    private func setupUI() {
        view.backgroundColor = .white
        setupChartView()
        setupChartSelectViewController()
        setupPointPopupViewController()
        setupDateIndicatorViewController()
        setupTapGestureRecognizer()
        setupTmpButton()
	}

    private func setupTmpButton() {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(tmpButtonTapped), for: .touchUpInside)
        button.setTitle("Switch model", for: .normal)
        button.frame = CGRect(x: self.view.bounds.midX - 100, y: self.view.bounds.maxY - 50, width: 200, height: 50)
        view.addSubview(button)
    }

    var tmpModels = [ChartViewControllerModel]()
    var tmpModelsIndex = 0

    @objc
    private func tmpButtonTapped() {
        model = tmpModels[tmpModelsIndex % 2]
        tmpModelsIndex += 1
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

    private func setLineHiddenFlags(_ flags:[Bool], animated: Bool = true) {
        model.lineHiddenFlags = flags

        for i in 0..<flags.count {
            chartView.setDataLineHidden(flags[i], at: i, animated: animated)
            chartSelectViewController.setDataLineHidden(flags[i], at: i, animated: animated)
        }
    }

    //TODO: remove
    private func setupData() {
		guard let data = ChartLoader.loadChartData() else {
			return
		}

		guard let charts = try? ChartJSONParser.charts(from: data) else {
			return
		}

        let model1 = ChartViewControllerModel(chart: charts[0])
        let model2 = ChartViewControllerModel(chart: charts[1])
        tmpModels = [model1, model2]
    }

    var tmpBothLines = true

    @objc
    private func handleTap(gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else {
            return
        }

        if tmpBothLines {
            tmpBothLines = false
        } else {
            tmpBothLines = true
        }

        var flags = lineHiddenFlags
        flags[0] = !tmpBothLines
        setLineHiddenFlags(flags, animated: true)
//        chartView.setDataLineHidden(!tmpBothLines, at: 0)
//        chartSelectViewController.setDataLineHidden(!tmpBothLines, at: 0)

        //TODO: remove when implemented line hiding
        return

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
}

// MARK: -

extension ChartViewController: ChartSelectViewControllerDelegate {

    func didSelectChartPartition(minUnitX: DataPoint.DataType, maxUnitX: DataPoint.DataType) {

        let range = minUnitX...maxUnitX

        model.selectedXRange = range
        selectedXRange = range
    }
}
