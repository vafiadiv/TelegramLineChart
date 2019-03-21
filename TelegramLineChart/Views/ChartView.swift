//
//  ChartView.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import UIKit

internal class ChartView: UIView {

	var debug = false

	var border = CGSize(width: 10, height: 10) {
		didSet {
			(self.layer as? ChartLayer)?.border = border
		}
	}

	///Data points of the chart in measurement units; assuming that are sorted in ascending order by X coordinate
	var dataLine: DataLine? {
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
		guard let dataLine = dataLine, !dataLine.points.isEmpty else {
			return
		}

		guard let ctx = UIGraphicsGetCurrentContext() else {
			return
		}

//		ctx.saveGState()
//		ctx.concatenate(CGAffineTransform(scaleX: 1, y: -1))
//		ctx.concatenate(CGAffineTransform(translationX: 0, y: -rect.height))
//		ctx.scaleBy(x: 1, y: -1)

		let drawingRect = rect.insetBy(dx: border.width, dy: border.height)

		//dimensions in chart measurement units
		let minUnitX = dataLine.points[0].x
		let maxUnitX = dataLine.points.last!.x

		var minUnitY = 0
		var maxUnitY = 0
		dataLine.points.forEach { point in
			if point.y < minUnitY {
				minUnitY = point.y
			}

			if point.y > maxUnitY {
				maxUnitY = point.y
			}
		}

		let pointsPerUnitX = type(of: self).pointsPerUnit(drawingDistance: drawingRect.width, unitMin: minUnitX, unitMax: maxUnitX)
		let pointsPerUnitY = type(of: self).pointsPerUnit(drawingDistance: drawingRect.height, unitMin: minUnitY, unitMax: maxUnitY)

		let path = UIBezierPath()
		path.lineWidth = 3.0
		ctx.setStrokeColor(dataLine.color.cgColor)

		for i in 0..<dataLine.points.count {
			let point = dataLine.points[i]
			let unitRelativeX = CGFloat(point.x - minUnitX)
			let unitRelativeY = CGFloat(point.y - minUnitY)

			let screenPoint = CGPoint(
					x: border.width + unitRelativeX * pointsPerUnitX,
					y: rect.height - border.height - (unitRelativeY * pointsPerUnitY))

			if i == 0 {
				path.move(to: screenPoint)
			} else {
				path.addLine(to: screenPoint)
			}

			if self.debug {
				type(of: self).drawCoordinates(x: point.x, y: point.y, at: screenPoint)
			}
		}

		path.stroke()

//		ctx.restoreGState()
	}

	private static func drawCoordinates(x: Int, y: Int, at point: CGPoint/*, in context: CGContext*/) {
		let string = "x: \(x), y: \(y)"
		NSString(string: string).draw(at: point, withAttributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
	}

	///Returns on-screen UIKit points per 1 of chart measurement units
	private static func pointsPerUnit(drawingDistance: CGFloat, unitMin: Int, unitMax: Int) -> CGFloat {
		return drawingDistance / CGFloat(unitMax - unitMin)
	}

}
