//
//  ChartSelectView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
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

    weak var delegate: ChartSelectViewDelegate?

    var chartView: ChartView!

    var selectionWindowView: ChartSelectWindowView!

    // MARK: - Private properties

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
        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.debug = false
        chartView.backgroundColor = .selectionChartBackground
        chartView.drawHorizontalLines = false
        addSubview(chartView)
    }

    private func setupSelectionWindow() {
        selectionWindowView = ChartSelectWindowView()
        selectionWindowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionWindowView)
    }

    private func setupGestureRecognizer() {
        gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
        addGestureRecognizer(gestureRecognizer)

        panHandler = SelectionWindowPanHandler(selectionWindowView: selectionWindowView)
        panHandler.delegate = self
    }

    // MARK: - Pan handling

    @objc
    private func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        self.panHandler.handlePan(of: gestureRecognizer, in: self)
    }

    // MARK: - Public methods

    //TODO: remove
    private var laidOutSelectionWindow = false

    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = self.bounds
        if !laidOutSelectionWindow {
            selectionWindowView.frame = self.bounds
            laidOutSelectionWindow = true
        }
        print("laid out views")
    }
}

extension ChartSelectView: SelectionWindowPanHandlerDelegate {

    fileprivate func didPanArea(_ area: SelectionWindowPanHandler.PanningArea, by translation: CGPoint) {
        let minX: CGFloat = 0
        let maxX = bounds.width
        switch area {
        case .leftSide:

            let leftAfterTranslation: CGFloat
            if selectionWindowView.frame.minX + translation.x < minX {
                leftAfterTranslation = minX
            } else if selectionWindowView.frame.minX + translation.x > maxX {
                leftAfterTranslation = maxX
            } else {
                leftAfterTranslation = selectionWindowView.frame.minX + translation.x
            }

            selectionWindowView.frame = CGRect(
                    x: leftAfterTranslation,
                    y: selectionWindowView.frame.y,
                    width: selectionWindowView.frame.maxX - leftAfterTranslation,
                    height: selectionWindowView.frame.height)

        case .rightSide:

            let widthAfterTranslation: CGFloat
            if selectionWindowView.frame.maxX + translation.x > maxX {
                widthAfterTranslation = maxX - selectionWindowView.frame.minX
            } else if selectionWindowView.frame.maxX + translation.x < minX {
                widthAfterTranslation = 0
            } else {
                widthAfterTranslation = selectionWindowView.frame.width + translation.x
            }
            selectionWindowView.frame = CGRect(
                    x: selectionWindowView.frame.x,
                    y: selectionWindowView.frame.y,
                    width: widthAfterTranslation,
                    height: selectionWindowView.frame.height)

        case .wholeWindow:
            let leftAfterTranslation = selectionWindowView.frame.minX + translation.x
            let rightAfterTranslation = selectionWindowView.frame.maxX + translation.x
            if leftAfterTranslation < minX {
                selectionWindowView.frame.x = minX
            } else if rightAfterTranslation > maxX {
                selectionWindowView.frame.x = maxX - selectionWindowView.frame.width
            } else {
                selectionWindowView.frame.x += translation.x
            }
        }

        self.delegate?.selectionWindowFrameDidChange()
    }
}

private class SelectionWindowPanHandler {

    internal enum PanningArea {
        case leftSide
        case rightSide
        case wholeWindow
    }

    private enum Constants {
        static let touchAreaWidth: CGFloat = 44.0
    }

    // MARK: - Public properties

    weak var delegate: SelectionWindowPanHandlerDelegate?

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

        if gestureRecognizer.state == .began {
            let touchLocation = gestureRecognizer.location(in: view)
            if centralTouchArea.contains(touchLocation) {
                panningArea = .wholeWindow
            } else if leftSideTouchArea.contains(touchLocation) {
                panningArea = .leftSide
            } else if rightSideTouchArea.contains(touchLocation) {
                panningArea = .rightSide
            }
        }

        if let panningArea = panningArea {
            self.delegate?.didPanArea(panningArea, by: translation)
        }

        gestureRecognizer.setTranslation(.zero, in: view.superview)
    }
}

private protocol SelectionWindowPanHandlerDelegate: AnyObject {
    func didPanArea(_ area: SelectionWindowPanHandler.PanningArea, by translation: CGPoint)
}
