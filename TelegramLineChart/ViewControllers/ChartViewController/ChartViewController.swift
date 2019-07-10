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

    private var tapGestureRecognizer: UITapGestureRecognizer!

    private var panGestureRecognizer: UIPanGestureRecognizer!

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

        //Since ChartViewController is a container, its view has to contain all other views that come from child ViewControllers.
        //Unfortunately, the proper setup of child view controllers and views has to be done in two methods and is kind of clunky
        //(add subview / add child / did move to parent)
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

        managedViewControllers.forEach { [unowned self] in
            $0.didMove(toParent: self)
        }
    }

    override func viewDidLoad() {
		super.viewDidLoad()

        setupGestureRecognizers()
        updateModel(model: model)
	}

    // MARK: - Private methods

    private func setupUI() {
        setupLineRangeSelectionViewController()
        setupLineSelectionViewController()
        setupPointPopupViewController()
        setupDateIndicatorViewController()
	}

    private func setupLineRangeSelectionViewController() {
        lineRangeSelectionViewController = LineRangeSelectionViewController()
        lineRangeSelectionViewController.delegate = self
    }

    private func setupPointPopupViewController() {
        pointPopupViewController = PointPopupViewController()
        pointPopupViewController.view.isHidden = true
    }

    private func setupDateIndicatorViewController() {
        chartDateIndicatorViewController = ChartDateIndicatorViewController()
    }

    private func setupLineSelectionViewController() {
        lineSelectionViewController = LineSelectionViewController()
        lineSelectionViewController.delegate = self
    }

    private func setupGestureRecognizers() {
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        rootView.chartView.addGestureRecognizer(tapGestureRecognizer)

        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
        panGestureRecognizer.delegate = self
        rootView.chartView.addGestureRecognizer(panGestureRecognizer)
    }

    private func setLineHiddenFlags(_ flags:[Bool], animated: Bool = true) {
        model.lineHiddenFlags = flags
        lineSelectionViewController.dataLineHiddenFlags = flags
        pointPopupViewController.dataLineHiddenFlags = flags

        for i in 0..<flags.count {
            rootView.chartView.setDataLineHidden(flags[i], at: i, animated: animated)
            lineRangeSelectionViewController.setDataLineHidden(flags[i], at: i, animated: animated)
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

    private func showPointPopupViewController(at tapPoint: CGPoint) {
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

    // MARK: - Touch handling

    @objc
    private func handleTap(gestureRecognizer: UITapGestureRecognizer) {

        guard pointPopupViewController.view.isHidden else {
            pointPopupViewController.view.setIsHiddenAnimated(true)
            return
        }

        let tapPoint = gestureRecognizer.location(in: rootView.chartView)

        showPointPopupViewController(at: tapPoint)
    }

    @objc
    private func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        let point = gestureRecognizer.location(in: gestureRecognizer.view?.superview)

        showPointPopupViewController(at: point)
    }
}

// MARK: -

extension ChartViewController: UIGestureRecognizerDelegate {

    //to allow this chart popup gesture recognizer to work simultaneously with scroll view's pan gesture recognizer
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer is UIPanGestureRecognizer
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

        if !pointPopupViewController.view.isHidden {
            pointPopupViewController.view.setIsHiddenAnimated(true)
        }
    }
}
