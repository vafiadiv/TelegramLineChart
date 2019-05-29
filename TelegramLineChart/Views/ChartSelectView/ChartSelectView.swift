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
        static let selectionWindowTouchArea: CGFloat = 90.0 //TODO: tmp
    }

    // MARK: - Public properties

    var dataLines = [DataLine]() {
        didSet {
            chartLayer.dataLines = dataLines
        }
    }

    ///
    ///Subrange of graph lines that should be displayed in full view
    var graphXRange: ClosedRange<DataPoint.DataType> = 0...0 {
        didSet {
            chartLayer.xRange = graphXRange
        }
    }

    weak var delegate: ChartSelectViewDelegate?

    ///
    ///Range of selected portion of the chart relative to the whole chart width.
    ///For both lowerBound and upperBound values < 0 and > 1.0 are ignored.
    var selectedRelativeRange: ClosedRange<CGFloat> = 0.75...1.0 {
        didSet {
            if selectedRelativeRange.lowerBound < 0 {
                selectedRelativeRange = 0...selectedRelativeRange.upperBound
            }

            if selectedRelativeRange.lowerBound > 1.0 {
                selectedRelativeRange = 1.0...1.0
            }

            if selectedRelativeRange.upperBound < 0 {
                selectedRelativeRange = 0...0
            }

            if selectedRelativeRange.upperBound > 1.0 {
                selectedRelativeRange = selectedRelativeRange.lowerBound...1.0
            }
        }
    }

    // MARK: - Private properties

    private var selectionWindowView: ChartSelectWindowView!

    private var gestureRecognizer: UIPanGestureRecognizer!

    private var panHandler: SelectionWindowPanHandler!

    private var chartLayer: ChartLayer {
        guard let chartLayer = layer as? ChartLayer else {
            fatalError("Wrong layer class")
        }
        return chartLayer
    }

    override class var layerClass: AnyClass {
        return ChartLayer.self
    }

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
        setupChartLayer()
        setupSelectionWindow()
        setupGestureRecognizer()
        self.backgroundColor = .white
    }

    private func setupChartLayer() {
        chartLayer.lineWidth = 1
        chartLayer.backgroundColor = UIColor.selectionChartBackground.cgColor
        chartLayer.drawHorizontalLines = false
        chartLayer.contentsScale = UIScreen.main.scale
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

    override func layoutSubviews() {
        super.layoutSubviews()

        let selectionMinX = bounds.maxX * selectedRelativeRange.lowerBound
        let selectionWidth = bounds.maxX * selectedRelativeRange.upperBound - selectionMinX
        selectionWindowView.frame = CGRect(x: selectionMinX, y: 0, width: selectionWidth, height: bounds.height)
    }
}

// MARK: -

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

        let minSelectionViewX = selectionWindowView.frame.minX
        let maxSelectionViewX = selectionWindowView.frame.maxX

        let minSelectedXRelative = minSelectionViewX / maxX
        let maxSelectedXRelative = maxSelectionViewX / maxX

        selectedRelativeRange = minSelectedXRelative...maxSelectedXRelative

        self.delegate?.selectedRangeDidChange()
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
