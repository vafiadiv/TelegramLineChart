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
        static let circleDiameter: CGFloat = 7.0

        static let lineWidth: CGFloat = 2.0

        static let popupTop: CGFloat = 5
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

        drawHighlightedPoint(at: pointInfos[0].point, to: context)

        context.setLineWidth(Constants.lineWidth)

        for pointInfo in pointInfos {
            let circleRect = CGRect(center: pointInfo.point, width: Constants.circleDiameter, height: Constants.circleDiameter)

            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: circleRect)

            context.setStrokeColor(pointInfo.color.cgColor)
            context.strokeEllipse(in: circleRect)
        }

        context.restoreGState()
    }

    // MARK: - Private methods

    private func drawHighlightedPoint(at point: CGPoint, to context: CGContext) {

        guard let pointInfos = pointInfos else {
            return
        }

        context.saveGState()

        //vertical line from popup to bottom
        context.setLineWidth(1.0)
        context.setStrokeColor(UIColor.chartPopupLine.cgColor)
        context.move(to: CGPoint(x: point.x, y: Constants.popupTop))
        context.addLine(to: CGPoint(x: point.x, y: bounds.height))
        context.strokePath()

        context.restoreGState()

        pointPopupDrawer.context = context
        pointPopupDrawer.drawPopup(atTopCenter: CGPoint(x: point.x, y: Constants.popupTop), pointInfos: pointInfos)
    }
}
