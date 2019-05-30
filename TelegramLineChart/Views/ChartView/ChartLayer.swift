//
//  ChartView.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import UIKit
import CoreGraphics

class ChartLayer: CALayer {

    //caseless enum to avoid instantiation
    private enum Constants {
        static let animationDuration: CFTimeInterval = 0.1

        //relative distance between horizontal chart lines measured in drawing rect height
        static let horizontalLinesRelativeY: CGFloat = 1 / 5
    }

    private struct AnimationInfo {

        var pointsPerUnitYPerSecond: CGFloat = 0

        var animationStartPointPerUnitY: CGFloat = 0

        var animationEndPointPerUnitY: CGFloat = 0

        var animationRemainingTime: CFTimeInterval = 0

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

    private var pointPopupDrawer = PointPopupDrawer()

    private var currentPointPerUnitY: CGFloat = 0

    private var lastDrawnTime: CFTimeInterval = 0

    private var animationInfo: AnimationInfo?

    private var displayLink: CADisplayLink?

    //TODO: remove, replace usages with self.bounds
    private var border = CGSize(width: 0, height: 0)

    private var linearFunctionFactory = LinearFunctionFactory<Double>()

    //data lines containing points that are visible at the moment; includes 2 "fake" edge points for drawing first
    //and last visible segment
    private var visibleDataLines = [DataLine]()

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

    // MARK: - Overrides

    override func draw(in context: CGContext) {
        super.draw(in: context)

        let rect = context.boundingBoxOfClipPath

        context.saveGState()

        updateVisibleDataLines()

        guard let displayLink = displayLink,
              !visibleDataLines.isEmpty else {
            return
        }


        let chartRect = rect.insetBy(dx: border.width, dy: border.height)

        //point with min Y value across all points in all lines
        let minY = dataLines.compactMap { dataLine in
            dataLine.points.map { $0.y }.min()
        }.min() ?? 0

        //point with max Y value across all points in all lines
        let maxY = visibleDataLines.compactMap { dataLine in
            dataLine.points.map { $0.y }.max()
        }.max() ?? 0

        let minDataPoint = DataPoint(x: xRange.lowerBound, y: minY)
        let maxDataPoint = DataPoint(x: xRange.upperBound, y: maxY)

        yRange = minY...maxY

        //calculate the required scale for the current data
        let pointsPerUnitXRequired = type(of: self).pointsPerUnit(drawingDistance: chartRect.width, unitMin: minDataPoint.x, unitMax: maxDataPoint.x)
        let pointsPerUnitYRequired = type(of: self).pointsPerUnit(drawingDistance: chartRect.height, unitMin: minDataPoint.y, unitMax: maxDataPoint.y)

        if currentPointPerUnitY == 0 {
            currentPointPerUnitY = pointsPerUnitYRequired
        }

        //TODO: tmp
        currentPointPerUnitY = pointsPerUnitYRequired

        //if an animation is in progress
        if let animationInfo = animationInfo {
            if pointsPerUnitYRequired == animationInfo.animationEndPointPerUnitY {

                lastDrawnTime = displayLink.timestamp

                //if animation is unfinished, advance currentPointPerUnitY towards targetPointPerUnitY
                if animationInfo.animationRemainingTime > 0 {

                    let frameDuration = displayLink.targetTimestamp - lastDrawnTime

                    currentPointPerUnitY += animationInfo.pointsPerUnitYPerSecond * CGFloat(frameDuration)

                    self.animationInfo?.animationRemainingTime -= frameDuration

                    self.animationInfo?.debugAnimationFramesNumber += 1

                } else {
                    //animation has reached its destination

                    print("<<< animation ended;")

                    currentPointPerUnitY = animationInfo.animationEndPointPerUnitY

                    self.animationInfo = nil

                    displayLink.isPaused = true
                }
            }
        }


        //start or restart the animation in 2 cases:
        //1. No animation is in progress and currentPointPerUnitY should be changed;
        //2. Animation is in progress, but animates towards a wrong value (animationEndPointPerUnitY). This can happen
        //   if pointPerUnitYRequired was changed during animation
        if (animationInfo == nil && pointsPerUnitYRequired != currentPointPerUnitY) ||
                   (animationInfo != nil && pointsPerUnitYRequired != animationInfo!.animationEndPointPerUnitY) {

            let pointsPerUnitYDiff = pointsPerUnitYRequired - currentPointPerUnitY

            animationInfo = AnimationInfo(
                    pointsPerUnitYPerSecond: pointsPerUnitYDiff / CGFloat(Constants.animationDuration),
                    animationStartPointPerUnitY: currentPointPerUnitY,
                    animationEndPointPerUnitY: pointsPerUnitYRequired,
                    animationRemainingTime: Constants.animationDuration,
                    debugAnimationFramesNumber: 0)
            lastDrawnTime = displayLink.timestamp

            displayLink.isPaused = false
            print(">>> animation started")
        }

        if drawHorizontalLines && maxY - minY > 0 {

            let lineUnitYs = Array(stride(from: minY, through: maxY, by: Int(CGFloat(maxY - minY) * Constants.horizontalLinesRelativeY)))

            let currentLinesAlpha: CGFloat

            if let animationInfo = animationInfo {

                currentLinesAlpha = CGFloat(animationInfo.animationRemainingTime / Constants.animationDuration)

                let animationEndLines = ChartHorizontalLinesDrawer.HorizontalLine.horizontalLines(
                        lineUnitYs: lineUnitYs,
                        minY: minY,
                        pointsPerUnitY: pointsPerUnitYRequired,
                        chartRect: chartRect)

                print("Drawing animation end lines: >\(animationEndLines.map { "\(Int($0.yPoint))-\($0.yUnit)" })")
                horizontalLinesDrawer.drawHorizontalLines(
                        lines: animationEndLines,
                        drawingRect: chartRect,
                        context: context,
                        alpha: 1 - currentLinesAlpha)
            } else {
                currentLinesAlpha = 1.0
            }

            let currentLines = ChartHorizontalLinesDrawer.HorizontalLine.horizontalLines(
                    lineUnitYs: lineUnitYs,
                    minY: minY,
                    pointsPerUnitY: currentPointPerUnitY,
                    chartRect: chartRect)

            print("Drawing       current lines: |\(currentLines.map { "\(Int($0.yPoint))-\($0.yUnit)" })")

            horizontalLinesDrawer.drawHorizontalLines(
                    lines: currentLines,
                    drawingRect: chartRect,
                    context: context,
                    alpha: currentLinesAlpha)
        }

        visibleDataLines.forEach { dataLine in
            drawLine(dataLine, to: context, in: chartRect, minDataPoint: minDataPoint, maxDataPoint: maxDataPoint, pointsPerUnitX: pointsPerUnitXRequired, pointsPerUnitY: currentPointPerUnitY)
        }

        context.restoreGState()
    }

    // MARK: - Private methods

    @objc
    private func displayLinkFire() {
        self.setNeedsDisplay()
    }

    private func updateVisibleDataLines() {
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

        visibleDataLines = dataLines.map {

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

            print("Now visible: left edge: \(leftEdgePoint), right edge: \(rightEdgePoint) for line \($0.name)")

            points[0] = leftEdgePoint
            points[points.count - 1] = rightEdgePoint

            return DataLine(points: points, color: $0.color, name: $0.name)
        }
    }

    private func drawLine(_ line: DataLine,
                          to context: CGContext,
                          in rect: CGRect,
                          minDataPoint: DataPoint,
                          maxDataPoint: DataPoint,
                          pointsPerUnitX: CGFloat,
                          pointsPerUnitY: CGFloat) {

        guard !line.points.isEmpty else {
            return
        }

        UIGraphicsPushContext(context)

        let path = UIBezierPath()
        path.lineWidth = lineWidth

        let points = ChartPointsCalculator.points(from: line.points, in: rect, bottomLeftPoint: minDataPoint, topRightPoint: maxDataPoint)

        for i in 0..<points.count {
            let point = points[i]

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }

            if debugDrawing {
                type(of: self).drawCoordinates(x: line.points[i].x, y: line.points[i].y, at: point)
            }
        }

        context.setStrokeColor(line.color.cgColor)
        path.lineJoinStyle = .round
        path.stroke()

        UIGraphicsPopContext()
    }

    ///Returns on-screen Core Graphics points per 1 of chart measurement units

    private static func pointsPerUnit(drawingDistance: CGFloat, unitMin: Int, unitMax: Int) -> CGFloat {
        return drawingDistance / CGFloat(unitMax - unitMin)
    }

    // MARK: - debug drawing

    private static func drawCoordinates(x: Int, y: Int, at point: CGPoint) {
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

extension DataLine {

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

// MARK: -

extension ChartHorizontalLinesDrawer.HorizontalLine {

    static func horizontalLines(
            lineUnitYs: [DataPoint.DataType],
            minY: DataPoint.DataType,
            pointsPerUnitY: CGFloat,
            chartRect: CGRect) -> [ChartHorizontalLinesDrawer.HorizontalLine] {

        let lines = lineUnitYs.map { yUnit -> ChartHorizontalLinesDrawer.HorizontalLine in
            let unitRelativeY = CGFloat(yUnit - minY)
            let yPoint = chartRect.maxY - floor(unitRelativeY * pointsPerUnitY)
            return ChartHorizontalLinesDrawer.HorizontalLine(yPoint: yPoint, yUnit: yUnit)
        }
        return lines
    }
}
