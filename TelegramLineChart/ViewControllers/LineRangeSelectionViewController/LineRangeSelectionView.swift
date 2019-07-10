//
//  LineRangeSelectionView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class LineRangeSelectionView: UIView {

    private enum Constants {
        static let mainChartViewYOffset: CGFloat = 3

        static let selectionWindowMinWidth: CGFloat = 26
    }

    // MARK: - Public properties

    var dataLines = [DataLine]() {
        didSet {
            mainChartView.dataLines = dataLines
        }
    }

    ///
    ///Subrange of graph lines that should be displayed in full view
    var graphXRange: ClosedRange<DataPoint.DataType> = 0...0 {
        didSet {
            mainChartView.xRange = graphXRange
        }
    }

    weak var delegate: LineRangeSelectionViewDelegate?

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

    private var selectionWindowView: LineRangeSelectionWindowView!

    private var panGestureRecognizer: UIPanGestureRecognizer!

    private var longPressGestureRecognizer: UILongPressGestureRecognizer!

    private var mainChartView: MainChartView!

    private var panHandler: SelectionWindowPanHandler!

    private var leftDimmingView: UIView!

    private var rightDimmingView: UIView!

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

    // MARK: - Public methods

    func setDataLineHidden(_ isHidden: Bool, at index: Int, animated: Bool = true) {
        mainChartView.setDataLineHidden(isHidden, at: index, animated: animated)
    }

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()

        mainChartView.frame = bounds.insetBy(dx: 0, dy: Constants.mainChartViewYOffset)

        let selectionMinX = bounds.maxX * selectedRelativeRange.lowerBound
        let selectionWidth = bounds.maxX * selectedRelativeRange.upperBound - selectionMinX
        selectionWindowView.frame = CGRect(x: selectionMinX, y: 0, width: selectionWidth, height: bounds.height)

        layoutDimmingViews()

        setNeedsDisplay()
    }

    private func layoutDimmingViews() {
        leftDimmingView.frame = CGRect(
                x: 0,
                y: mainChartView.frame.y,
                width: selectionWindowView.frame.minX,
                height: mainChartView.frame.height)
        rightDimmingView.frame = CGRect(
                x: selectionWindowView.frame.maxX,
                y: mainChartView.frame.y,
                width: bounds.width - selectionWindowView.frame.maxX,
                height: mainChartView.frame.height)
    }

    // MARK: - Private methods
    
    private func setupUI() {
        setupMainChartView()
        setupSelectionWindow()
        setupDimmingViews()
        setupGestureRecognizer()
    }

    private func setupSelectionWindow() {
        selectionWindowView = LineRangeSelectionWindowView()
        selectionWindowView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectionWindowView)
    }

    private func setupDimmingViews() {
        leftDimmingView = UIView()
        rightDimmingView = UIView()

        leftDimmingView.backgroundColor = .selectionChartBackground
        rightDimmingView.backgroundColor = .selectionChartBackground

        rightDimmingView.isOpaque = false
        leftDimmingView.isOpaque = false

        addSubview(leftDimmingView)
        addSubview(rightDimmingView)
    }

    private func setupGestureRecognizer() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gestureRecognizer:)))
        addGestureRecognizer(panGestureRecognizer)

        //we need to detect touch down events on the view, so tap gesture recognizer won't do the trick. Instead,
        //we use a longPressGestureRecognizer with minimumPressDuration = 0
        longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureRecognizer:)))
        longPressGestureRecognizer.minimumPressDuration = 0
        longPressGestureRecognizer.delegate = self
        addGestureRecognizer(longPressGestureRecognizer)

        panHandler = SelectionWindowPanHandler(selectionWindowView: selectionWindowView)
        panHandler.delegate = self
    }

    private func setupMainChartView() {
        mainChartView = MainChartView()
        mainChartView.drawHorizontalLines = false
        mainChartView.lineWidth = 1.0
        mainChartView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainChartView)
    }

    // MARK: - Pan handling

    @objc
    private func handlePan(gestureRecognizer: UIPanGestureRecognizer) {
        self.panHandler.handlePan(of: gestureRecognizer, in: self)
    }

    @objc
    private func handleTap(gestureRecognizer: UILongPressGestureRecognizer) {
        self.panHandler.handleTap(of: gestureRecognizer, in: self)
    }
}

// MARK: -

extension LineRangeSelectionView: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer == panGestureRecognizer
    }
}

// MARK: -

extension LineRangeSelectionView: SelectionWindowPanHandlerDelegate {

    fileprivate func didPanArea(_ area: SelectionWindowPanHandler.PanningArea, by translation: CGPoint) {

        switch area {
        case .leftSide:

            let minX: CGFloat = 0
            let maxX = selectionWindowView.frame.maxX - Constants.selectionWindowMinWidth

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

            self.selectionWindowView.isLeftHighlighted = true
            self.selectionWindowView.isRightHighlighted = false

        case .rightSide:

            let minX = selectionWindowView.frame.minX + Constants.selectionWindowMinWidth
            let maxX = bounds.width

            let widthAfterTranslation: CGFloat

            if selectionWindowView.frame.maxX + translation.x > maxX {
                widthAfterTranslation = maxX - selectionWindowView.frame.minX
            } else if selectionWindowView.frame.maxX + translation.x < minX {
                widthAfterTranslation = Constants.selectionWindowMinWidth
            } else {
                widthAfterTranslation = selectionWindowView.frame.width + translation.x
            }
            selectionWindowView.frame = CGRect(
                    x: selectionWindowView.frame.x,
                    y: selectionWindowView.frame.y,
                    width: widthAfterTranslation,
                    height: selectionWindowView.frame.height)

            self.selectionWindowView.isLeftHighlighted = false
            self.selectionWindowView.isRightHighlighted = true

        case .wholeWindow:

            let minX: CGFloat = 0
            let maxX = bounds.width

            let leftAfterTranslation = selectionWindowView.frame.minX + translation.x
            let rightAfterTranslation = selectionWindowView.frame.maxX + translation.x

            if leftAfterTranslation < minX {
                selectionWindowView.frame.x = minX
            } else if rightAfterTranslation > maxX {
                selectionWindowView.frame.x = maxX - selectionWindowView.frame.width
            } else {
                selectionWindowView.frame.x += translation.x
            }

            self.selectionWindowView.isLeftHighlighted = true
            self.selectionWindowView.isRightHighlighted = true
        }

        layoutDimmingViews()

        let minSelectionViewX = selectionWindowView.frame.minX
        let maxSelectionViewX = selectionWindowView.frame.maxX

        let minSelectedXRelative = minSelectionViewX / bounds.width
        let maxSelectedXRelative = maxSelectionViewX / bounds.width

        selectedRelativeRange = minSelectedXRelative...maxSelectedXRelative

        self.delegate?.selectedRangeDidChange()
    }

    fileprivate func didFinishPanning() {
        self.selectionWindowView.isLeftHighlighted = false
        self.selectionWindowView.isRightHighlighted = false
    }
}

// MARK: -

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
                x: selectionWindowView.frame.minX - Constants.touchAreaWidth / 2,
                y: selectionWindowView.frame.y,
                width: Constants.touchAreaWidth,
                height: selectionWindowView.frame.height)
    }

    private var rightSideTouchArea: CGRect {
        return CGRect(
                x: selectionWindowView.frame.maxX - Constants.touchAreaWidth / 2,
                y: selectionWindowView.frame.y,
                width: Constants.touchAreaWidth,
                height: selectionWindowView.frame.height)
    }

    private var centralTouchArea: CGRect {
        return CGRect(
                x: selectionWindowView.frame.minX + Constants.touchAreaWidth / 2,
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

        guard gestureRecognizer.state != .ended else {
            self.delegate?.didFinishPanning()
            return
        }

        if gestureRecognizer.state == .began {
            panningArea = panningArea(of: gestureRecognizer.location(in: view))
        }

        if let panningArea = panningArea {
            let translation = gestureRecognizer.translation(in: view.superview)
            self.delegate?.didPanArea(panningArea, by: translation)
        }

        gestureRecognizer.setTranslation(.zero, in: view.superview)
    }

    func handleTap(of gestureRecognizer: UILongPressGestureRecognizer, in view: UIView) {
        switch gestureRecognizer.state {
        case .began:
            if let panningArea = panningArea(of: gestureRecognizer.location(in: view)) {
                self.delegate?.didPanArea(panningArea, by: .zero)
            }
        case .ended:
            self.delegate?.didFinishPanning()
        default:
            return
        }
    }

    func panningArea(of touchLocation: CGPoint) -> PanningArea? {
        var panningArea: PanningArea?

        if centralTouchArea.contains(touchLocation) {
            panningArea = .wholeWindow
        } else if leftSideTouchArea.contains(touchLocation) {
            panningArea = .leftSide
        } else if rightSideTouchArea.contains(touchLocation) {
            panningArea = .rightSide
        }

        return panningArea
    }
}

// MARK: -

private protocol SelectionWindowPanHandlerDelegate: AnyObject {
    func didPanArea(_ area: SelectionWindowPanHandler.PanningArea, by translation: CGPoint)

    func didFinishPanning()
}
