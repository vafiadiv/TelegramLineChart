//
//  ChartPopupLayer.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartPopupLayer: CALayer {

    // MARK: - Private types

    private enum Constants {
        static let circleDiameter: CGFloat = 8.0
        static let lineWidth: CGFloat = 1.0
    }

    // MARK: - Public properties

    var pointInfos: [ChartPopupPointInfo]? {
        didSet {
            setNeedsDisplay()
        }
    }

    // MARK: - Private properties

    private var pointPopupDrawer = PointPopupDrawer()

    // MARK: - Overrides

    override func draw(in context: CGContext) {
        super.draw(in: context)

        context.saveGState()

        guard let pointInfos = pointInfos, !pointInfos.isEmpty else {
            return
        }

        context.setLineWidth(Constants.lineWidth)

        for pointInfo in pointInfos {
            context.setStrokeColor(pointInfo.color.cgColor)
            context.addEllipse(in: CGRect(center: pointInfo.point, width: Constants.circleDiameter, height: Constants.circleDiameter))
            context.strokePath()
        }

        context.restoreGState()

        drawHighlightedPoint(at: pointInfos[0].point, to: context)
    }

    // MARK: - Private methods

    private func drawHighlightedPoint(at point: CGPoint, to context: CGContext) {

//        let chartUnitWidth = CGFloat(xRange.upperBound - xRange.lowerBound)
//        let highlightedUnitX = xRange.lowerBound + DataPoint.DataType(chartUnitWidth * point.x / bounds.width)
//
//        guard xRange ~= highlightedUnitX else {
//            return
//        }

        context.saveGState()

        context.setStrokeColor(UIColor.chartPopupBackground.cgColor)
        context.move(to: CGPoint(x: point.x, y: 0))
        context.addLine(to: CGPoint(x: point.x, y: bounds.height))
        context.strokePath()

        context.restoreGState()

        pointPopupDrawer.context = context
        pointPopupDrawer.drawPopup(atTopCenter: CGPoint(x: point.x, y: 6))
    }
}
