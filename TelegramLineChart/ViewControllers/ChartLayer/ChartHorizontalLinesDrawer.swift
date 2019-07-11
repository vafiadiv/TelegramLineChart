//
//  ChartHorizontalLinesDrawer.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import UIKit
import CoreGraphics

internal struct ChartHorizontalLinesDrawer {

    struct HorizontalLine {
        let yPoint: CGFloat
        let yUnit: DataPoint.DataType
    }

    //enum to avoid instantiation
    private enum Constants {

        static let textOffset = UIOffset(horizontal: 0, vertical: 0)

        static let fontSize: CGFloat = 11

        static let horizontalLinesCount: CGFloat = 5

        static let formatter = AbbreviatedNumberFormatter()

        static let color = UIColor(white: 0, alpha: 0.05)
    }

    // MARK: - Public methods

    internal func drawHorizontalLines(linesYRange: ClosedRange<DataPoint.DataType>,
                                      drawingRectYRange: ClosedRange<DataPoint.DataType>,
                                      drawingRect: CGRect,
                                      context: CGContext,
                                      alpha: CGFloat = 1,
                                      debugPrint: Bool = false) {

        let lineUnitYs = Array(stride(
                from: linesYRange.lowerBound,
                through: linesYRange.upperBound,
                by: DataPoint.DataType(CGFloat(linesYRange.upperBound - linesYRange.lowerBound) / Constants.horizontalLinesCount)))

        let pointsPerUnitY = drawingRect.height / CGFloat(drawingRectYRange.upperBound - drawingRectYRange.lowerBound)

        let lines = horizontalLines(lineUnitYs: lineUnitYs, minY: drawingRectYRange.lowerBound, pointsPerUnitY: pointsPerUnitY, chartRect: drawingRect)

        UIGraphicsPushContext(context)

        let minX = drawingRect.minX + Constants.textOffset.horizontal
        let maxX = drawingRect.maxX - Constants.textOffset.horizontal

        let linePath = UIBezierPath()
        linePath.move(to: CGPoint(x: minX, y: 0))
        context.setStrokeColor(Constants.color.withAlphaComponent(0.05 * alpha).cgColor)
        context.setLineWidth(1.0)
        lines.forEach {
            linePath.move(to: CGPoint(x: minX, y: $0.yPoint))
            linePath.addLine(to: CGPoint(x: maxX, y: $0.yPoint))
        }

        linePath.stroke()

/*
        let lineTexts = lineYCoordinates.map {
            floor(Double($0)).abbreviated
        }
*/

        let lineTextPoints = lines.map {
            return CGPoint(x: minX, y: $0.yPoint - Constants.textOffset.vertical)
        }

        zip(lines, lineTextPoints).forEach { line, point in
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: Constants.fontSize, weight: .light),
                .foregroundColor: UIColor.chartHorizontalLinesText.withAlphaComponent(alpha)
            ]

            let yUnitNumber = NSNumber(integerLiteral: line.yUnit)
            let attributedText = NSAttributedString(string: Constants.formatter.string(from: yUnitNumber) ?? "", attributes: attributes)
            let size = attributedText.size().ceiled
            attributedText.draw(at: CGPoint(x: point.x, y: point.y - size.height - Constants.textOffset.vertical))
        }

        UIGraphicsPopContext()

    }

    // MARK: - Private methods

    private func horizontalLines(
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
