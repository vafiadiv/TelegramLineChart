//
//  ChartSelectView.swift
//  ArtFit
//
//  Created by Valentin Vafiadi on 2019-05-15.
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartSelectView: UIView {

    private enum Constants {
        static let selectionWindowTouchArea: CGFloat = 44.0
    }

    // MARK: - Public properties

    var dataLines = [DataLine]() {
        didSet {
            chartView.dataLines = dataLines
        }
    }

    // MARK: - Private properties

    private var chartView: ChartView!

    private var selectionWindowView: ChartSelectWindowView!

    private var gestureRecognizer: UIPanGestureRecognizer!

    private var panHandler: SelectionWindowPanHandler!

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
        setupGestureRecognizer()
    }

    private func setupChartView() {
        chartView = ChartView()
        chartView.backgroundColor = .selectionChartBackground
        chartView.drawHorizontalLines = false
        addSubview(chartView)
    }

    private func setupSelectionWindow() {
        selectionWindowView = ChartSelectWindowView()
        addSubview(selectionWindowView)
    }

    private func setupGestureRecognizer() {
        gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
        addGestureRecognizer(gestureRecognizer)

        panHandler = SelectionWindowPanHandler(selectionWindowView: selectionWindowView)
    }

    // MARK: - Pan handling

    @objc
    private func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        self.panHandler.handlePan(of: gestureRecognizer, in: self)
/*
        let translation = gestureRecognizer.translation(in: superview)
        print("moved by: \(translation.x)")

        switch gestureRecognizer.location(in: self).x {
        case selectionWindow.frame.x - Constants.selectionWindowTouchArea / 2
            ..<
            selectionWindow.frame.x + Constants.selectionWindowTouchArea / 2:

            print("left side")
        default:
            break
        }
        selectionWindow.frame.origin.x += translation.x
        gestureRecognizer.setTranslation(.zero, in: superview)
*/
    }

    // MARK: - Public methods

    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = self.bounds
        selectionWindowView.frame = self.bounds
    }
}

private class SelectionWindowPanHandler {

    private enum PanningArea {
        case leftSide
        case rightSide
        case wholeWindow
    }

    private enum Constants {
        static let touchAreaWidth: CGFloat = 44.0
    }

    // MARK: - Private properties

    private let selectionWindowView: UIView

    private var panningArea: PanningArea?

    private var leftSideTouchArea: CGRect {
        return CGRect(
                x: selectionWindowView.frame.left - Constants.touchAreaWidth / 2,
                y: selectionWindowView.frame.y,
                width: Constants.touchAreaWidth,
                height: selectionWindowView.frame.height)
    }

    private var rightSideTouchArea: CGRect {
        return CGRect(
                x: selectionWindowView.frame.right - Constants.touchAreaWidth / 2,
                y: selectionWindowView.frame.y,
                width: Constants.touchAreaWidth,
                height: selectionWindowView.frame.height)
    }

    private var centralTouchArea: CGRect {
        return CGRect(
                x: selectionWindowView.frame.left + Constants.touchAreaWidth / 2,
                y: selectionWindowView.frame.y,
                width: selectionWindowView.frame.width - Constants.touchAreaWidth,
                height: selectionWindowView.frame.height)
    }

    // MARK: - Initialization

    init(selectionWindowView: UIView) {
        self.selectionWindowView = selectionWindowView
    }

    // MARK: - Public methods

    func handlePan(of gestureRecognizer: UIPanGestureRecognizer, in view: UIView) {
        let translation = gestureRecognizer.translation(in: view.superview)
//        print("moved by: \(translation.x)")

        if gestureRecognizer.state == .began {
            let touchLocation = gestureRecognizer.location(in: view)
            if centralTouchArea.contains(touchLocation) {
                panningArea = .wholeWindow
            } else if leftSideTouchArea.contains(touchLocation) {
                panningArea = .leftSide
            } else if rightSideTouchArea.contains(touchLocation) {
                panningArea = .rightSide
            }

            print("panning: \(panningArea)")
        }

        selectionWindowView.frame.origin.x += translation.x
        gestureRecognizer.setTranslation(.zero, in: view.superview)
    }
}
