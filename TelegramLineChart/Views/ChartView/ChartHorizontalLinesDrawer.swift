//
//  ChartHorizontalLinesDrawer.swift
//  Copyright © 2019 Cleverpumpkin, Ltd. All rights reserved.
//

import UIKit
import CoreGraphics

internal class ChartHorizontalLinesDrawer {

    struct HorizontalLine {
        let yPoint: CGFloat
        let yUnit: DataPoint.YType
    }

	//enum to avoid instantiation
	private enum Constants {

        static let textOffset = UIOffset(horizontal: 5, vertical: 0)
	}

    internal func drawHorizontalLines(lines: [HorizontalLine],
                                      drawingRect: CGRect,
                                      context: CGContext,
                                      alpha: CGFloat = 1,
                                      debugPrint: Bool = false) {

//        let distanceBetweenLines = drawingRect.height * Constants.horizontalLinesRelativeY

//        var lineYCoordinates = [CGFloat]()
//        lineYCoordinates = Array(stride(from: drawingRect.height, through: 0, by: -distanceBetweenLines)) //TODO: replace drawingRect.height with unit

        context.saveGState()
        context.translateBy(x: drawingRect.x, y: drawingRect.y)

        let linePath = UIBezierPath()
        linePath.move(to: CGPoint.zero)
//        context.setStrokeColor(UIColor.chartHorizontalLines.withAlphaComponent(alpha).cgColor)
        context.setStrokeColor(UIColor.chartHorizontalLines.cgColor)
        context.setLineWidth(1.0)
        lines.forEach {
            linePath.move(to: CGPoint(x: 0, y: $0.yPoint))
            linePath.addLine(to: CGPoint(x: drawingRect.width, y: $0.yPoint))
        }

        linePath.stroke()
        context.restoreGState()

/*
        let lineTexts = lineYCoordinates.map {
            floor(Double($0)).abbreviated
        }
*/

        let lineTextPoints = lines.map {
            return CGPoint(x: Constants.textOffset.horizontal, y: $0.yPoint - Constants.textOffset.vertical)
        }

        zip(lines, lineTextPoints).forEach { line, point in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.chartHorizontalLinesText.withAlphaComponent(alpha)
            ]

            let attributedText = NSAttributedString(string: Double(line.yUnit).abbreviated, attributes: attributes)
            let size = attributedText.size().ceiled
            attributedText.draw(at: CGPoint(x: point.x, y: point.y - size.height - Constants.textOffset.vertical))
        }
    }

	internal func drawHorizontalLines(currentPointsPerUnitY: CGFloat,
									  drawingRect: CGRect,
									  context: CGContext,
									  debugPrint: Bool = false) {

	}
}
