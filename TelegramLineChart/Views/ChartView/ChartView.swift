//
//  ChartView.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import UIKit
import CoreGraphics

internal class ChartView: UIView {

    //caseless enum to avoid instantiation
    private enum Constants {
        static let animationDuration: CFTimeInterval = 0.5

        //relative distance between horizontal chart lines measured in drawing rect height
        static let horizontalLinesRelativeY: CGFloat = 1 / 5
    }

    private struct AnimationInfo {

        var pointsPerUnitYPerSecond: CGFloat = 0

        var animationStartPointPerUnitY: CGFloat = 0

        var animationEndPointPerUnitY: CGFloat = 0

/*
        var animationStartMinY: DataPoint.YType = 0

        var animationEndMinY: DataPoint.YType = 0
*/

        var animationRemainingTime: CFTimeInterval = 0

        var debugAnimationFramesNumber: Int = 0

    }

	// MARK: - Public properties

    var lineWidth: CGFloat = 2.0

	///Data points of the chart in measurement units; assuming that are sorted in ascending order by X coordinate
	var dataLines = [DataLine]() {
		didSet {

            let firstPoints = dataLines.compactMap { $0.points.first?.x }

            let lastPoints = dataLines.compactMap { $0.points.last?.x }

            let minX = firstPoints.min() ?? 0
            let maxX = lastPoints.max() ?? minX

            xRange = minX...maxX

            setNeedsDisplay()
		}
	}

    var xRange: ClosedRange<DataPoint.XType> = 0...0 { //TODO: make private? Should be for drawing 2 edge points offscreen
        didSet {
            setNeedsDisplay()
        }
    }

    var drawHorizontalLines: Bool = true

    var debug = false

    // MARK: - Private properties

    private var currentPointPerUnitY: CGFloat = 0

    private var lastDrawnTime: CFTimeInterval = 0

    private var animationInfo: AnimationInfo?

    private var displayLink: CADisplayLink?

    private var border = CGSize(width: 10, height: 10)

	private let horizontalLinesDrawer = ChartHorizontalLinesDrawer()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        isOpaque = true
        displayLink = CADisplayLink(target: self, selector: #selector(displayLinkFire))
        displayLink?.isPaused = true
        displayLink?.add(to: .main, forMode: .default)
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Public methods

    @objc
    private func displayLinkFire() {
        self.setNeedsDisplay()
    }

	override func draw(_ rect: CGRect) {
		super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext(),
              let displayLink = displayLink,
              !dataLines.isEmpty else {
            return
        }

		let chartRect = rect.insetBy(dx: border.width, dy: border.height)

        //point with min Y value across all points in all lines
/*
        let minY = dataLines.compactMap { dataLine in
            dataLine.points.map { $0.y }.min()
        }.min() ?? 0
*/

        let minY = 0 //TODO: decide, whether or not the y = 0 line should always be visible. Pro: no weird jumps when scrolling, con: high-value parts will be poorly visible

        //point with max Y value across all points in all lines
        let maxY = dataLines.compactMap { dataLine in
            dataLine.points.map { $0.y }.max()
        }.max() ?? 0

        let minDataPoint = DataPoint(x: xRange.lowerBound, y: minY)
        let maxDataPoint = DataPoint(x: xRange.upperBound, y: maxY)

        //calculate the required scale for the current data
        let pointsPerUnitXRequired = type(of: self).pointsPerUnit(drawingDistance: chartRect.width, unitMin: minDataPoint.x, unitMax: maxDataPoint.x)
        let pointsPerUnitYRequired = type(of: self).pointsPerUnit(drawingDistance: chartRect.height, unitMin: minDataPoint.y, unitMax: maxDataPoint.y)

        if currentPointPerUnitY == 0 {
            currentPointPerUnitY = pointsPerUnitYRequired
        }

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
/*
                    print("""
                          <<< animation ended;
                             current pointsPerUnitY: \(currentPointPerUnitY)
                             target pointsPerUnitY: \(animationInfo.animationEndPointPerUnitY) (equal: \(currentPointPerUnitY == animationInfo.animationEndPointPerUnitY))
                             reached in \(animationInfo.debugAnimationFramesNumber) frames
                          """)
*/

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

            self.animationInfo = AnimationInfo(
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

                let animationEndLines = ChartHorizontalLinesDrawer.HorizontalLine.lines(
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


            let currentLines = ChartHorizontalLinesDrawer.HorizontalLine.lines(
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

        dataLines.forEach { dataLine in
            drawLine(dataLine, minDataPoint: minDataPoint, pointsPerUnitX: pointsPerUnitXRequired, pointsPerUnitY: currentPointPerUnitY, in: chartRect, in: context)
        }
    }

	// MARK: - Private methods

	private func drawLine(_ line: DataLine,
                          minDataPoint: DataPoint,
                          pointsPerUnitX: CGFloat,
                          pointsPerUnitY: CGFloat,
                          in rect: CGRect,
                          in context: CGContext) {

		guard !line.points.isEmpty else {
			return
		}

		context.saveGState()

		let path = UIBezierPath()
		path.lineWidth = lineWidth

		for i in 0..<line.points.count {
			let point = line.points[i]
			let unitRelativeX = CGFloat(point.x - minDataPoint.x)
			let unitRelativeY = CGFloat(point.y - minDataPoint.y)

			let screenPoint = CGPoint(
					x: rect.origin.x + unitRelativeX * pointsPerUnitX,
					y: rect.origin.y + rect.height - (unitRelativeY * pointsPerUnitY))

			if i == 0 {
				path.move(to: screenPoint)
			} else {
				path.addLine(to: screenPoint)
			}

			if debug {
				type(of: self).drawCoordinates(x: point.x, y: point.y, at: screenPoint)
			}
		}
		context.setStrokeColor(line.color.cgColor)
		path.lineJoinStyle = .round
		path.stroke()

		context.restoreGState()
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

		NSString(string: string).draw(at: point, withAttributes: [NSAttributedString.Key.foregroundColor: UIColor.cyan])
		context.restoreGState()
	}
}

extension ChartHorizontalLinesDrawer.HorizontalLine {

    static func lines(
            lineUnitYs: [DataPoint.YType],
            minY: DataPoint.YType,
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
