//
//  ChartView.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import UIKit
import CoreGraphics

class ChartLayer: CALayer {

    //caseless enum to avoid instantiation
    private enum Constants {
        static let animationDuration: CFTimeInterval = 0.25

        //after calculating minY and maxY points of visible part of the graph, the space has to be extended up and down
        //by `additionalYSpaceRelative` to avoid min and max points "hugging" the edges
        static let additionalYSpaceRelative = 0.15
    }

    private struct AnimationInfo {

        var unitYRangeStart: ClosedRange<DataPoint.DataType>

        var unitYRangeEnd: ClosedRange<DataPoint.DataType>

        //TODO: remove?
        var animationEndPointPerUnitY: CGFloat

        var animationRemainingTime: CFTimeInterval

        var debugAnimationFramesNumber: Int = 0
    }

    // MARK: - Public properties

    var lineWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    ///Data points of the chart in measurement units; assuming that are sorted in ascending order by X coordinate
    var dataLines = [DataLine]() {
        didSet {
            lineAlphas = [CGFloat](repeating: 1.0, count: dataLines.count)
            lineTargetHiddenFlags = [Bool](repeating: false, count: dataLines.count)
            lineCurrentHiddenFlags = [Bool](repeating: false, count: dataLines.count)
            skipAnimation = true
            setNeedsDisplay()
        }
    }

    var xRange: ClosedRange<DataPoint.DataType> = 0...0 {
        didSet {
            setNeedsDisplay()
        }
    }

    private(set) var yRange: ClosedRange<DataPoint.DataType> = 0...0

    var drawHorizontalLines: Bool = true {
        didSet {
            setNeedsDisplay()
        }
    }

    //TODO: remove, replace usages with self.bounds
    var border = CGSize(width: 0, height: 0)

    var debugDrawing = false

    // MARK: - Private properties

    private var horizontalLinesDrawer = ChartHorizontalLinesDrawer()

    private var currentPointPerUnitY: CGFloat {
        return (bounds.height - 2 * border.height) / CGFloat(yRange.upperBound - yRange.lowerBound)
    }

    private var lastDrawnTime: CFTimeInterval = 0

    private var animationInfo: AnimationInfo?

    private var animationEnabled = true

    private var displayLink: CADisplayLink?

    private var animationDelayTimer: Timer?

    private var linearFunctionFactory = LinearFunctionFactory<Double>()

    //data lines containing points that are inside xRange; includes 2 "fake" edge points for drawing first and last
    //visible segment
    private var onScreenLines = [DataLine]()

    private var lineAlphas = [CGFloat]()

    private var lineTargetHiddenFlags = [Bool]()

    private var lineCurrentHiddenFlags = [Bool]()

    private var skipAnimation: Bool = true

    // MARK: - Initialization

    override init() {
        super.init()
        isOpaque = true
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFire))
        displayLink?.isPaused = true
        displayLink?.add(to: .main, forMode: .default)
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Public methods

    func setDataLineHidden(_ isHidden: Bool, at index: Int, animated: Bool = true) {
        lineTargetHiddenFlags[index] = isHidden
        if animated {
            animationEnabled = true
        } else {
            lineCurrentHiddenFlags[index] = isHidden
            lineAlphas[index] = isHidden ? 0.0 : 1.0
        }
        setNeedsDisplay()
    }

    // MARK: - Overrides

    override func draw(in context: CGContext) {
        super.draw(in: context)

        let rect = context.boundingBoxOfClipPath

        context.saveGState()

        updateOnScreenLines()

        guard !onScreenLines.isEmpty else {
            return
        }

        let chartRect = rect.insetBy(dx: border.width, dy: border.height)

        var visibleLines = [DataLine]()
        for i in 0..<onScreenLines.count {
            if !lineTargetHiddenFlags[i] {
                visibleLines.append(onScreenLines[i])
            }
        }

        //point with min Y value across all points in all lines
        let minVisibleY = visibleLines.compactMap { dataLine in
            dataLine.points.map { $0.y }.min()
        }.min() ?? 0

        //point with max Y value across all points in all lines
        let maxVisibleY = visibleLines.compactMap { dataLine in
            dataLine.points.map { $0.y }.max()
        }.max() ?? 0

        let additionalYSpace = DataPoint.DataType(Double(maxVisibleY) * Constants.additionalYSpaceRelative)
        let minY = max(minVisibleY - additionalYSpace, 0)
        let maxY = maxVisibleY + additionalYSpace

        if skipAnimation {
            yRange = minY...maxY
            skipAnimation = false
        }

        //calculate the required scale for the current data
        let pointsPerUnitXRequired = chartRect.width / CGFloat(xRange.upperBound - xRange.lowerBound)
        let pointsPerUnitYRequired = chartRect.height / CGFloat(maxY - minY)

        //if an animation is in progress
        if let animationInfo = animationInfo {
            advanceAnimation(animationInfo: animationInfo)
        }

        //start or restart the animation in 2 cases:
        //1. No animation is in progress and currentPointPerUnitY should be changed;
        //2. Animation is in progress, but animates towards a wrong value (animationEndPointPerUnitY). This can happen
        //   if pointPerUnitYRequired was changed during animation
        if (animationInfo == nil && pointsPerUnitYRequired != currentPointPerUnitY) ||
           (animationInfo != nil && pointsPerUnitYRequired != animationInfo!.animationEndPointPerUnitY) {

            if animationEnabled {
                startAnimation(pointsPerUnitY: pointsPerUnitYRequired, yRangeEnd: minY...maxY)
            } else {
                animationRequired()
            }
        }

        if drawHorizontalLines && maxY > minY {

            if let animationInfo = animationInfo, animationEnabled {

                let currentLinesAlpha = CGFloat(animationInfo.animationRemainingTime / Constants.animationDuration)

                horizontalLinesDrawer.drawHorizontalLines(
                        linesYRange: animationInfo.unitYRangeStart,
                        drawingRectYRange: yRange,
                        drawingRect: chartRect,
                        context: context,
                        alpha: currentLinesAlpha)

                horizontalLinesDrawer.drawHorizontalLines(
                        linesYRange: animationInfo.unitYRangeEnd,
                        drawingRectYRange: yRange,
                        drawingRect: chartRect,
                        context: context,
                        alpha: 1 - currentLinesAlpha)
            } else {
                horizontalLinesDrawer.drawHorizontalLines(
                        linesYRange: yRange,
                        drawingRectYRange: yRange,
                        drawingRect: chartRect,
                        context: context)
            }
        }

        for i in 0..<onScreenLines.count {
            drawLine(onScreenLines[i],
                    to: context,
                    in: chartRect,
                    minDataPoint: DataPoint(x: xRange.lowerBound, y: minY),
                    pointsPerUnitX: pointsPerUnitXRequired,
                    pointsPerUnitY: currentPointPerUnitY,
                    alpha: lineAlphas[i])
        }

        context.restoreGState()

        if (debugDrawing) {
            debugDrawMinMaxY(context: context, minY: minY, maxY: maxY)
        }
    }

    // MARK: - Private methods

    // MARK: - Animation

    private func advanceAnimation(animationInfo: AnimationInfo) {
        guard let displayLink = displayLink else {
            return
        }

        lastDrawnTime = displayLink.timestamp

        //if animation is unfinished, advance currentPointPerUnitY towards targetPointPerUnitY
        if animationInfo.animationRemainingTime > 0 {

            let minYStart = animationInfo.unitYRangeStart.lowerBound
            let maxYStart = animationInfo.unitYRangeStart.upperBound
            let minYEnd = animationInfo.unitYRangeEnd.lowerBound
            let maxYEnd = animationInfo.unitYRangeEnd.upperBound

            let frameDuration = displayLink.targetTimestamp - lastDrawnTime
            let frameDurationRelative = frameDuration / Constants.animationDuration
            let remainingTimeRelative = animationInfo.animationRemainingTime  / Constants.animationDuration

            let unitYMinDiff = Double(minYEnd - minYStart) * frameDurationRelative
            let unitYMaxDiff = Double(maxYEnd - maxYStart) * frameDurationRelative

            yRange = DataPoint.DataType(Double(yRange.lowerBound) + unitYMinDiff)...DataPoint.DataType(Double(yRange.upperBound) + unitYMaxDiff)

            for i in 0..<onScreenLines.count {
                let targetHidden = lineTargetHiddenFlags[i]
                let currentHidden = lineCurrentHiddenFlags[i]
                if targetHidden != currentHidden {
                    lineAlphas[i] = CGFloat(targetHidden ? remainingTimeRelative : (1.0 - remainingTimeRelative))
                }
            }

            self.animationInfo?.animationRemainingTime -= frameDuration
            self.animationInfo?.debugAnimationFramesNumber += 1

        } else {
            //animation has reached its destination
            animationDidEnd(animationInfo: animationInfo)
        }
    }

    private func animationRequired() {

        if animationDelayTimer == nil || !animationDelayTimer!.isValid {
            print("||| animation required")
            animationDelayTimer = Timer.scheduledTimer(withTimeInterval: Constants.animationDuration, repeats: false) { [weak self] _ in
                self?.animationEnabled = true
                self?.setNeedsDisplay()
            }
        }
    }

    //TODO: remove pointsPerUnitY? Pro: readability, con: re-calculating it => slight performance loss
    private func startAnimation(pointsPerUnitY: CGFloat, yRangeEnd: ClosedRange<DataPoint.DataType>) {
        guard let displayLink = displayLink else {
            return
        }

        animationInfo = AnimationInfo(
                unitYRangeStart: yRange,
                unitYRangeEnd: yRangeEnd,
                animationEndPointPerUnitY: pointsPerUnitY,
                animationRemainingTime: Constants.animationDuration,
                debugAnimationFramesNumber: self.animationInfo?.debugAnimationFramesNumber ?? 0)
        lastDrawnTime = displayLink.timestamp

        displayLink.isPaused = false
        print(">>> animation started; animating to \(animationInfo?.animationEndPointPerUnitY ?? 0)")
    }

    private func animationDidEnd(animationInfo: AnimationInfo) {
        print("<<< animation ended; reached in \(animationInfo.debugAnimationFramesNumber)")
        self.animationInfo?.debugAnimationFramesNumber = 0
        yRange = animationInfo.unitYRangeEnd
        self.animationInfo = nil

        displayLink?.isPaused = true
        for i in 0..<onScreenLines.count {
            let targetHidden = lineTargetHiddenFlags[i]
            lineCurrentHiddenFlags[i] = targetHidden
            lineAlphas[i] = targetHidden ? 0.0 : 1.0
        }

        animationEnabled = false
    }

    @objc
    private func displayLinkFire() {
        self.setNeedsDisplay()
    }

    // MARK: - Data lines

    private func updateOnScreenLines() {
//TODO: comment
/*
        1. найти ближайшую слева точку к lowerBound (lowerThanLowerBound, lowerThanLowerBoundIndex):
            2.1 бежим по dataLine, если lowerBound < текущей:
               если (индекс текущей > 0) - берём (индекс текущей - 1)
               иначе берём 0.
       2. Аналогично ближайшую справа от upperBound;
       3. Находим пересечение lowerBound и линии (lowerThanLowerBound, lowerThanLowerBound+1) - это minFakePoint
       4. Находим пересечение upperBound и линии (higherThanUpperBound-1, higherThanUpperBound) - это maxFakePoint
       4.5 - сделать guard на lowerThanLowerBoundIndex+1 > higherThanUpperBound-1 ?
       5. Возвращаем [minFakePoint, lowerThanLowerBoundIndex+1, ... higherThanUpperBound-1, maxFakePoint]
*/

        onScreenLines = dataLines.map {

            //1. To find visible portion of the graph in `xRange` first we need to find all that are on the screen (inside xRange)
            // plus two points that are just outside of it (to the left and to the right).
            var points = $0.points(containing: xRange)

            guard let pointOutsideRangeLeft = points.first,
                  let pointOutsideRangeRight = points.last,
                  points.count > 1 else {
                return $0
            }

            //2. Find points where edge lines intersect the edges of the screen (i.e. vertical lines y = xRange.lowerBound and
            // y = xRange.upperBound)
            let pointInsideRangeLeft = points[1]

            let leftEdgeIntersectingLine = linearFunctionFactory.function(
                    x1: Double(pointOutsideRangeLeft.x),
                    y1: Double(pointOutsideRangeLeft.y),
                    x2: Double(pointInsideRangeLeft.x),
                    y2: Double(pointInsideRangeLeft.y))

            let leftEdgeY = leftEdgeIntersectingLine(Double(xRange.lowerBound))
            let leftEdgePoint = DataPoint(x: xRange.lowerBound, y: DataPoint.DataType(leftEdgeY))

            let pointInsideRangeRight = points[points.count - 2]
            let rightEdgeIntersectingLine = linearFunctionFactory.function(
                    x1: Double(pointOutsideRangeRight.x),
                    y1: Double(pointOutsideRangeRight.y),
                    x2: Double(pointInsideRangeRight.x),
                    y2: Double(pointInsideRangeRight.y))

            let rightEdgeY = rightEdgeIntersectingLine(Double(xRange.upperBound))
            let rightEdgePoint = DataPoint(x: xRange.upperBound, y: DataPoint.DataType(rightEdgeY))

//            print("Now visible: left edge: \(leftEdgePoint), right edge: \(rightEdgePoint) for line \($0.name)")

            points[0] = leftEdgePoint
            points[points.count - 1] = rightEdgePoint

            var dataLine = $0
            dataLine.points = points
            return dataLine
        }
    }

    private func drawLine(_ line: DataLine,
                          to context: CGContext,
                          in rect: CGRect,
                          minDataPoint: DataPoint,
                          pointsPerUnitX: CGFloat,
                          pointsPerUnitY: CGFloat,
                          alpha: CGFloat = 1.0) {

        guard !line.points.isEmpty, alpha != 0 else {
            return
        }

        UIGraphicsPushContext(context)

        let path = UIBezierPath()
        path.lineWidth = lineWidth

        let points = ChartPointsCalculator.points(
                from: line.points,
                in: rect,
                bottomLeftPoint: minDataPoint,
                pointsPerUnitX: pointsPerUnitX,
                pointsPerUnitY: pointsPerUnitY)

        for i in 0..<points.count {
            let point = points[i]

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }

            if debugDrawing {
                self.debugDrawCoordinates(x: line.points[i].x, y: line.points[i].y, at: point)
            }
        }

        context.setStrokeColor(line.color.withAlphaComponent(alpha).cgColor)
//        print("Drawing line \(line.name) with alpha = \(alpha)")
        path.lineJoinStyle = .round
        path.stroke()

        UIGraphicsPopContext()
    }

    // MARK: - debug drawing

    private func debugDrawMinMaxY(context: CGContext, minY: DataPoint.DataType, maxY: DataPoint.DataType) {
        UIGraphicsPushContext(context)

        let string = """
                     minY = \(minY)
                     maxY = \(maxY)
                     """
        NSString(string: string).draw(at: .zero, withAttributes: [NSAttributedString.Key.foregroundColor: UIColor.black])

        UIGraphicsPopContext()
    }

    private func debugDrawCoordinates(x: Int, y: Int, at point: CGPoint) {
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        context.saveGState()
//		let string = "x: \(x), y: \(y)"
        let string = "y: \(y)"

        NSString(string: string).draw(at: point, withAttributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
        context.restoreGState()
    }
}

// MARK: -

private extension DataLine {

    //Returns minimal continuous array of points from the line so that minPoint.x < xRange.lowerBound && maxPoint.x > xRange.upperBound
    //I.e. for points.x = [1, 3, 5, 7, 9] and xRange = 4...6 returns [3, 5, 7]
    func points(containing xRange: ClosedRange<DataPoint.DataType>) -> [DataPoint] {

        let indexInsideRangeLeft = points.firstIndex { $0.x >= xRange.lowerBound }
        let indexOutsideRangeLeft: Int

        if let indexInsideRangeLeft = indexInsideRangeLeft {
            indexOutsideRangeLeft = indexInsideRangeLeft > 0 ? indexInsideRangeLeft - 1 : 0
        } else {
            indexOutsideRangeLeft = points.count - 1
        }

        let indexInsideRangeRight = points.lastIndex { $0.x <= xRange.upperBound }
        let indexOutsideRangeRight: Int

        if let indexInsideRangeRight = indexInsideRangeRight {
            indexOutsideRangeRight = indexInsideRangeRight < points.count - 1 ? indexInsideRangeRight + 1 : points.count - 1
        } else {
            indexOutsideRangeRight = indexOutsideRangeLeft
        }

        if indexOutsideRangeLeft <= indexOutsideRangeRight {
            return Array(points[indexOutsideRangeLeft...indexOutsideRangeRight])
        } else {
            return Array(points[indexOutsideRangeLeft...indexOutsideRangeLeft])
        }
    }
}
