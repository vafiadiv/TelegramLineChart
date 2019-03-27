//
//  ChartView.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import UIKit
import CoreGraphics

internal class ChartView: UIView {

	var debug = true

	var border = CGSize(width: 10, height: 10) {
		didSet {
			(self.layer as? ChartLayer)?.border = border
		}
	}

	///Data points of the chart in measurement units; assuming that are sorted in ascending order by X coordinate
	var dataLines = [DataLine]() {
		didSet {
//			(self.layer as? ChartLayer)?.dataLine = dataLine
			self.setNeedsDisplay()
		}
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.layer.bounds = self.bounds
	}

/*
	override class var layerClass: AnyClass {
		return ChartLayer.self
	}
*/

	override func draw(_ rect: CGRect) {
		super.draw(rect)

		guard let context = UIGraphicsGetCurrentContext() else {
			return
		}

		guard !self.dataLines.isEmpty else {
			return
		}

//		ctx.saveGState()
//		ctx.concatenate(CGAffineTransform(scaleX: 1, y: -1))
//		ctx.concatenate(CGAffineTransform(translationX: 0, y: -rect.height))
//		ctx.scaleBy(x: 1, y: -1)

		let drawingRect = rect.insetBy(dx: border.width, dy: border.height)

		if self.debug {
			context.saveGState()
			context.setStrokeColor(UIColor.brown.cgColor)
			context.stroke(drawingRect, width: 3.0)
			context.restoreGState()
		}

		self.dataLines.forEach { dataLine in
			self.drawPoints(dataLine.points, in: drawingRect, with: dataLine.color, in: context)
		}
//		ctx.restoreGState()
	}

	private func drawPoints(_ points: [DataPoint], in rect: CGRect, with color: UIColor, in context: CGContext) {
		guard !points.isEmpty else {
			return
		}

		context.saveGState()

		//dimensions in chart measurement units
		let minUnitX = points[0].x
		//force-unwrap is safe since `poits` is not empty
		let maxUnitX = points.last!.x

		var minUnitY = 0
		var maxUnitY = 0
		points.forEach { point in
			if point.y < minUnitY {
				minUnitY = point.y
			}

			if point.y > maxUnitY {
				maxUnitY = point.y
			}
		}

		let pointsPerUnitX = type(of: self).pointsPerUnit(drawingDistance: rect.width, unitMin: minUnitX, unitMax: maxUnitX)
		let pointsPerUnitY = type(of: self).pointsPerUnit(drawingDistance: rect.height, unitMin: minUnitY, unitMax: maxUnitY)

		let path = UIBezierPath()
		path.lineWidth = 3.0

		for i in 0..<points.count {
			let point = points[i]
			let unitRelativeX = CGFloat(point.x - minUnitX)
			let unitRelativeY = CGFloat(point.y - minUnitY)

			let screenPoint = CGPoint(
					x: rect.origin.x + unitRelativeX * pointsPerUnitX,
					y: rect.origin.y + rect.height - (unitRelativeY * pointsPerUnitY))

			if i == 0 {
				path.move(to: screenPoint)
			} else {
				path.addLine(to: screenPoint)
			}

			if self.debug {
				type(of: self).drawCoordinates(x: point.x, y: point.y, at: screenPoint)
			}
		}
		context.setStrokeColor(color.cgColor)
		path.lineJoinStyle = .round
		path.stroke()

		context.restoreGState()
	}

	///Returns on-screen Core Graphics points per 1 of chart measurement units
	private static func pointsPerUnit(drawingDistance: CGFloat, unitMin: Int, unitMax: Int) -> CGFloat {
		return drawingDistance / CGFloat(unitMax - unitMin)
	}

	// MARK: - debug drawing

	private static func drawCoordinates(x: Int, y: Int, at point: CGPoint/*, in context: CGContext*/) {
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
