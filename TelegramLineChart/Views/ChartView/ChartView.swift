//
//  ChartView.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import UIKit
import CoreGraphics

internal class ChartView: UIView {

	// MARK: - Public properties

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

    var xRange: ClosedRange<DataPoint.XType> = 0...0 {
        didSet {
            setNeedsDisplay()
        }
    }

    var drawHorizontalLines: Bool = true

    var debug = true

    // MARK: - Private properties

	private var border = CGSize(width: 10, height: 10)

	private let horizontalLinesDrawer = ChartHorizontalLinesDrawer()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Public methods

	override func layoutSubviews() {
		super.layoutSubviews()
		layer.bounds = bounds
	}

	override func draw(_ rect: CGRect) {
		super.draw(rect)

		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}

		guard !dataLines.isEmpty else {
			return
		}

		let drawingRect = rect.insetBy(dx: border.width, dy: border.height)

/*
		if debug {
			context.saveGState()
			context.setStrokeColor(UIColor.brown.cgColor)
			context.stroke(drawingRect, width: 3.0)
			context.restoreGState()
		}
*/

        //point with min Y value across all points in all lines
        let minY = dataLines.compactMap { dataLine in
            dataLine.points.map { $0.y }.min()
        }.min() ?? 0

        //point with max Y value across all points in all lines
        let maxY = dataLines.compactMap { dataLine in
            dataLine.points.map { $0.y }.max()
        }.max() ?? minY

        let minPoint = DataPoint(x: xRange.lowerBound, y: minY)
        let maxPoint = DataPoint(x: xRange.upperBound, y: maxY)

        dataLines.forEach { dataLine in
//            drawLine(dataLine, in: drawingRect, in: context)
            drawLine(dataLine, minDataPoint: minPoint, maxDataPoint: maxPoint, in: drawingRect, in: context)
		}

	}

	// MARK: - Private methods

	private func drawLine(_ line: DataLine, minDataPoint: DataPoint, maxDataPoint: DataPoint, in rect: CGRect, in context: CGContext) {
		guard !line.points.isEmpty else {
			return
		}

		context.saveGState()

/*
		//dimensions in chart measurement units
		let minUnitX = line.points[0].x
		//force-unwrap is safe since `points` is not empty
		let maxUnitX = line.points.last!.x

		var minUnitY = 0
		var maxUnitY = 0
        line.points.forEach { point in
			if point.y < minUnitY {
				minUnitY = point.y
			}

			if point.y > maxUnitY {
				maxUnitY = point.y
			}
		}
*/

		let pointsPerUnitX = type(of: self).pointsPerUnit(drawingDistance: rect.width, unitMin: minDataPoint.x, unitMax: maxDataPoint.x)
		let pointsPerUnitY = type(of: self).pointsPerUnit(drawingDistance: rect.height, unitMin: minDataPoint.y, unitMax: maxDataPoint.y)

		let path = UIBezierPath()
		path.lineWidth = 3.0

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

        if drawHorizontalLines {
            horizontalLinesDrawer.drawHorizontalLines(
                    currentPointsPerUnitY: pointsPerUnitY,
                    newPointsPerUnitY: pointsPerUnitY,
                    drawingRect: rect,
                    context: context)
        }
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
