//
//  ViewController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi on 17/03/2019.
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController, RootViewProtocol {

    typealias RootViewType = ChartView

    private enum Constants {

        static let tempChartViewTop: CGFloat = 54

        static let tempChartViewBottom: CGFloat = 30

        static let chartViewHeight: CGFloat = 288

        static let chartViewXOffset: CGFloat = 16

        static let LineRangeSelectionViewHeight: CGFloat = 43

        static let popupAnimationInterval: TimeInterval = 0.25
    }

    // MARK: - Public properties

    var model: ChartViewControllerModel {
        didSet {
            updateModel(model: model)
        }
    }

    private func updateModel(model: ChartViewControllerModel) {

        rootView.chartView.dataLines = model.lines
        lineRangeSelectionViewController.dataLines = model.lines
        pointPopupViewController.dataLines = model.lines
        lineSelectionViewController.dataLines = model.lines

        selectedXRange = model.selectedXRange
        chartDateIndicatorViewController.totalXRange = model.lines.xRange

        setLineHiddenFlags(model.lineHiddenFlags, animated: false)

        view.setNeedsLayout()
    }

    // MARK: - Private properties

    private var selectedXRange: ClosedRange<DataPoint.DataType> {
        didSet {
            model.selectedXRange = selectedXRange

            rootView.chartView.xRange = selectedXRange

            if !pointPopupViewController.view.isHidden {
                pointPopupViewController.view.setIsHiddenAnimated(true)
            }
            chartDateIndicatorViewController.visibleXRange = selectedXRange
        }
    }

//    private var chartView: MainChartView!

    private var tapGestureRecognizer: UITapGestureRecognizer!

    private var lineRangeSelectionViewController: LineRangeSelectionViewController!

    private var pointPopupViewController: PointPopupViewController!

    private var chartDateIndicatorViewController: ChartDateIndicatorViewController!

    private var lineSelectionViewController: LineSelectionViewController!

    //ViewControllers that are created by ChartViewController and added as children
    private var managedViewControllers = [UIViewController]()

    // MARK: - Initialization

    init(model: ChartViewControllerModel) {
        self.model = model
        self.selectedXRange = model.selectedXRange

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Overrides

    override func loadView() {

        setupUI()

        view = ChartView(
                lineRangeSelectionView: lineRangeSelectionViewController.rootView,
                pointPopupView: pointPopupViewController.rootView,
                chartDateIndicatorView: chartDateIndicatorViewController.rootView,
                lineSelectionView: lineSelectionViewController.rootView)

        managedViewControllers = [
            lineRangeSelectionViewController,
            pointPopupViewController,
            chartDateIndicatorViewController,
            lineSelectionViewController]

        managedViewControllers.forEach { [unowned self] in
            self.addChild($0)
        }
    }

    override func viewDidLoad() {
		super.viewDidLoad()

        managedViewControllers.forEach { [unowned self] in
            $0.didMove(toParent: self)
        }
        setupTapGestureRecognizer()
        updateModel(model: model)
	}

/*
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        let widthWithOffset = view.frame.width - 2 * Constants.chartViewXOffset

        chartView.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: 0,
                width: widthWithOffset,
                height: Constants.chartViewHeight)

        chartDateIndicatorViewController.view.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: chartView.frame.maxY,
                width: widthWithOffset,
                height: Constants.tempChartViewBottom)

        lineRangeSelectionViewController.view.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: chartView.frame.maxY + Constants.tempChartViewBottom,
                width: widthWithOffset,
                height: Constants.LineRangeSelectionViewHeight)

        let maxHeightSize = CGSize(width: widthWithOffset, height: .greatestFiniteMagnitude)
        lineSelectionViewController.view.frame = CGRect(
                x: Constants.chartViewXOffset,
                y: lineRangeSelectionViewController.view.frame.maxY,
                width: widthWithOffset,
                height: lineSelectionViewController.view.sizeThatFits(maxHeightSize).height)

*/
/*
        lineSelectionViewController.view.frame.size = CGSize(width: widthWithOffset, height: .greatestFiniteMagnitude)
        lineSelectionViewController.view.sizeToFit()
        lineSelectionViewController.view.frame.origin = CGPoint(
                x: Constants.chartViewXOffset,
                y: lineSelectionViewController.view.frame.maxY)
*//*


//                CGRect(
//                x: Constants.chartViewXOffset,
//                y: lineRangeSelectionViewController.view.frame.maxY,
//                width: widthWithOffset,
//                height: lineRangeSelectionViewController.view.)
//        )

        //TODO: reset popupVC's frame
    }
*/

    // MARK: - Private methods

    private func setupUI() {
//        view.backgroundColor = .white
//        setupChartView()
        setupLineRangeSelectionViewController()
        setupLineSelectionViewController()
        setupPointPopupViewController()
        setupDateIndicatorViewController()
	}

/*
    private func setupChartView() {
        chartView = MainChartView()
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.backgroundColor = .white
        view.addSubview(chartView)
    }
*/

    private func setupLineRangeSelectionViewController() {
        lineRangeSelectionViewController = LineRangeSelectionViewController()
        lineRangeSelectionViewController.delegate = self

        setupChildViewController(lineRangeSelectionViewController)
    }

    private func setupPointPopupViewController() {
        pointPopupViewController = PointPopupViewController()
        pointPopupViewController.view.isHidden = true

        setupChildViewController(pointPopupViewController)
    }

    private func setupDateIndicatorViewController() {
        chartDateIndicatorViewController = ChartDateIndicatorViewController()
        //TODO: remove?
        chartDateIndicatorViewController.view.backgroundColor = .white

        setupChildViewController(chartDateIndicatorViewController)
    }

    private func setupLineSelectionViewController() {
        lineSelectionViewController = LineSelectionViewController()
        lineSelectionViewController.delegate = self

        setupChildViewController(lineSelectionViewController)
    }

    private func setupTapGestureRecognizer() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        rootView.chartView.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupChildViewController(_ viewController: UIViewController) {
/*
        addChild(viewController)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(viewController.view)
        viewController.didMove(toParent: self)
*/
    }

    private func setLineHiddenFlags(_ flags:[Bool], animated: Bool = true) {
        model.lineHiddenFlags = flags
        lineSelectionViewController.dataLineHiddenFlags = flags

        for i in 0..<flags.count {
            rootView.chartView.setDataLineHidden(flags[i], at: i, animated: animated)
            lineRangeSelectionViewController.setDataLineHidden(flags[i], at: i, animated: animated)
        }
    }

    @objc
    private func handleTap(gestureRecognizer: UITapGestureRecognizer) {

        guard pointPopupViewController.view.isHidden else {
            pointPopupViewController.view.setIsHiddenAnimated(true)
            return
        }

        let tapPoint = gestureRecognizer.location(in: rootView.chartView)

        let dataRect = DataRect(
                origin: DataPoint(x: rootView.chartView.xRange.lowerBound, y: rootView.chartView.yRange.lowerBound),
                width: rootView.chartView.xRange.upperBound - rootView.chartView.xRange.lowerBound,
                height: rootView.chartView.yRange.upperBound - rootView.chartView.yRange.lowerBound)

        pointPopupViewController.setupWith(tapPoint: tapPoint, visibleDataRect: dataRect, chartRect: rootView.chartView.bounds)
        let size = pointPopupViewController.view.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: rootView.chartView.frame.height))
        let tapPointInSelf = self.view.convert(tapPoint, from: rootView.chartView)
        pointPopupViewController.view.frame = CGRect(center: CGPoint(x: tapPointInSelf.x, y: rootView.chartView.center.y), size: size)
        pointPopupViewController.view.setIsHiddenAnimated(false)
    }
}

// MARK: -

extension ChartViewController: LineRangeSelectionViewControllerDelegate {

    func didSelectChartPartition(minUnitX: DataPoint.DataType, maxUnitX: DataPoint.DataType) {

        let range = minUnitX...maxUnitX

        model.selectedXRange = range
        selectedXRange = range
    }
}

// MARK: -

extension ChartViewController: LineSelectionViewControllerDelegate {
    func didSelectLine(at index: Int) {
        var hiddenFlags = model.lineHiddenFlags

        var numberOfVisibleLines = 0
        hiddenFlags.forEach {
            if $0 == false {
                numberOfVisibleLines += 1
            }
        }

        //hiding all lines make no sense from UX standpoint, so skip the flag switch if we are trying to hide the last
        //visible line
        guard numberOfVisibleLines > 1 || hiddenFlags[index] else {
            return
        }

        hiddenFlags[index] = !hiddenFlags[index]
        setLineHiddenFlags(hiddenFlags)
    }
}
