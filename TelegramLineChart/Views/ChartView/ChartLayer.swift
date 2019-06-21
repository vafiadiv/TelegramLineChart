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

        //relative distance between horizontal chart lines measured in drawing rect height
        static let horizontalLinesRelativeY: CGFloat = 1 / 5
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

    var lineWidth: CGFloat = 2.0 {
        didSet {
            setNeedsDisplay()
        }
    }

    ///Data points of the chart in measurement units; assuming that are sorted in ascending order by X coordinate
    var dataLines = [DataLine]() {
        didSet {
            linesAlpha = [CGFloat](repeating: 1.0, count: dataLines.count)
            lineTargetHiddenFlags = [Bool](repeating: false, count: dataLines.count)
            lineCurrentHiddenFlags = [Bool](repeating: false, count: dataLines.count)
            animationEnabled = true
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

    var debugDrawing = false

    // MARK: - Private properties

    private var horizontalLinesDrawer = ChartHorizontalLinesDrawer()

    private var currentPointPerUnitY: CGFloat {
        return bounds.height / CGFloat(yRange.upperBound - yRange.lowerBound)
    }

    private var lastDrawnTime: CFTimeInterval = 0

    private var animationInfo: AnimationInfo?

    private var animationEnabled = true

    private var displayLink: CADisplayLink?

    private var animationDelayTimer: Timer?

    //TODO: remove, replace usages with self.bounds
    private var border = CGSize(width: 0, height: 0)

    private var linearFunctionFactory = LinearFunctionFactory<Double>()

    //data lines containing points that are inside xRange; includes 2 "fake" edge points for drawing first and last
    //visible segment
    private var onScreenLines = [DataLine]()

    private var linesAlpha = [CGFloat]()

    private var lineTargetHiddenFlags = [Bool]()

    private var lineCurrentHiddenFlags = [Bool]()

    // MARK: - Initialization

    override init() {
        super.init()
        backgroundColor = UIColor.white.cgColor
        isOpaque = true
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFire))
        displayLink?.isPaused = true
        displayLink?.add(to: .main, forMode: .default)
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Public methods

    func setDataLineHidden(_ isHidden: Bool, at index: Int) {
        dataLines[index].targetHidden = isHidden
        animationEnabled = true
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

        let visibleLines = onScreenLines.compactMap { !$0.targetHidden ? $0 : nil }

        //point with min Y value across all points in all lines
        let minY = visibleLines.compactMap { dataLine in
            dataLine.points.map { $0.y }.min()
        }.min() ?? 0

        //point with max Y value across all points in all lines
        let maxY = visibleLines.compactMap { dataLine in
            dataLine.points.map { $0.y }.max()
        }.max() ?? 0

        if yRange == 0...0 {
            yRange = minY...maxY
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

        onScreenLines.forEach { dataLine in
            if dataLine.alpha == 0 { //TODO: currentHidden instead?
                return
            }

            drawLine(dataLine,
                    to: context,
                    in: chartRect,
                    minDataPoint: DataPoint(x: xRange.lowerBound, y: minY),
                    pointsPerUnitX: pointsPerUnitXRequired,
                    pointsPerUnitY: currentPointPerUnitY)
        }

        context.restoreGState()

        if (debugDrawing) {
            debugDrawMinMaxY(context: context, minY: minY, maxY: maxY)
        }
    }

    // MARK: - Private methods

    // MARK: - Animation

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

        let pointsPerUnitYDiff = pointsPerUnitY - currentPointPerUnitY

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

    private func animationDidEnd() {
        animationEnabled = false
    }

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
                let line = onScreenLines[i]
                if line.targetHidden != line.currentHidden {
                    onScreenLines[i].alpha = CGFloat(line.targetHidden ? remainingTimeRelative : (1.0 - remainingTimeRelative))
                }
            }

            self.animationInfo?.animationRemainingTime -= frameDuration
            self.animationInfo?.debugAnimationFramesNumber += 1

        } else {
            //animation has reached its destination

            print("<<< animation ended; reached in \(animationInfo.debugAnimationFramesNumber)")
            self.animationInfo?.debugAnimationFramesNumber = 0
            yRange = animationInfo.unitYRangeEnd
            self.animationInfo = nil

            displayLink.isPaused = true
            for i in 0..<onScreenLines.count {
                let targetHidden = onScreenLines[i].targetHidden
                onScreenLines[i].currentHidden = targetHidden
                onScreenLines[i].alpha = targetHidden ? 0.0 : 1.0
            }

            animationDidEnd()
        }
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
                          pointsPerUnitY: CGFloat) {

        guard !line.points.isEmpty else {
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

        context.setStrokeColor(line.color.withAlphaComponent(line.alpha).cgColor)
        print("Drawing line \(line.name) with alpha = \(line.alpha)")
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
