//
//  ChartHorizontalLinesDrawer.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import UIKit
import CoreGraphics

internal class ChartHorizontalLinesDrawer {

	//enum to avoid instantiation
	private enum Constants {
		//relative distance between horizontal chart lines measured in drawing rect height
		static let horizontalLinesRelativeY: CGFloat = 1 / 5.5
        static let textOffset = UIOffset(horizontal: 5, vertical: 5)
	}

	internal func drawHorizontalLines(currentPointsPerUnitY: CGFloat,
									  newPointsPerUnitY: CGFloat,
									  drawingRect: CGRect,
									  context: CGContext,
									  debugPrint: Bool = false) {

//		let currentPointsPerUnitY = type(of: self).pointsPerUnit(drawingDistance: drawingRect.height, unitMin: currentUnitMinY, unitMax: currentUnitMaxY)
//        let newPointsPerUnitY = self.pointsPerUnit(drawingDistance: drawingRect.height, unitMin: newUnitMinY, unitMax: newUnitMaxY)

		let distanceBetweenLines = drawingRect.height * Constants.horizontalLinesRelativeY

		var lineYCoordinates = [CGFloat]()
		lineYCoordinates = Array(stride(from: drawingRect.height, through: 0, by: -distanceBetweenLines))

		context.saveGState()
		context.translateBy(x: drawingRect.x, y: drawingRect.y)

		let linePath = UIBezierPath()
		linePath.move(to: CGPoint.zero)
		context.setStrokeColor(UIColor.gray.cgColor)
		context.setLineWidth(1.0)
		lineYCoordinates.forEach { lineYCoordinate in
			linePath.move(to: CGPoint(x: 0, y: lineYCoordinate))
			linePath.addLine(to: CGPoint(x: drawingRect.width, y: lineYCoordinate))
		}

		linePath.stroke()
		context.restoreGState()

		let lineTexts = lineYCoordinates.map {
			floor(Double($0)).abbreviated
		}

		let lineTextPoints = lineYCoordinates.map {
			return CGPoint(x: Constants.textOffset.horizontal, y: $0 - Constants.textOffset.vertical)
		}

		zip(lineTexts, lineTextPoints).forEach { text, point in
			let attributes: [NSAttributedString.Key: Any] = [
				.font: UIFont.systemFont(ofSize: 15),
				.foregroundColor: UIColor.init(white: 0.7, alpha: 1)
			]

		 	let attributedText = NSAttributedString(string: text, attributes: attributes)
			let size = attributedText.size().ceiled
			attributedText.draw(at: CGPoint(x: point.x, y: point.y - size.height - Constants.textOffset.vertical))
		}
	}
}
