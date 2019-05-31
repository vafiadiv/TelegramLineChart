//
//  PointPopupView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class PointPopupView: UIView {

    //Data transfer object containing all info necessary for drawing

    struct DTO {
        var monthDay: String

        var year: String

        var pointInfos: [ChartPopupPointInfo]
    }

    private enum Constants {
        static let circleDiameter: CGFloat = 7.0

        static let lineWidth: CGFloat = 2.0

        static let popupTop: CGFloat = 5
    }

    // MARK: - Public properties

    var DTO: DTO?

    // MARK: - Private properties

    private var pointPopupDrawer = PointPopupDrawer()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.isUserInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Overrides

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.saveGState()

        guard let DTO = self.DTO, !DTO.pointInfos.isEmpty else {
            return
        }

        drawVerticalLine(at: bounds.center.x, to: context)

        context.setLineWidth(Constants.lineWidth)

        for pointInfo in DTO.pointInfos {
            let circleRect = CGRect(center: CGPoint(x: bounds.center.x, y: pointInfo.pointY), width: Constants.circleDiameter, height: Constants.circleDiameter)

            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: circleRect)

            context.setStrokeColor(pointInfo.color.cgColor)
            context.strokeEllipse(in: circleRect)
        }

        context.restoreGState()

        pointPopupDrawer.context = context
        pointPopupDrawer.drawPopup(atTopCenter: CGPoint(x: bounds.center.x, y: Constants.popupTop), pointInfos: DTO.pointInfos)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 94, height: size.height)
    }

    // MARK: - Private methods

    private func drawVerticalLine(at pointX: CGFloat, to context: CGContext) {

        context.saveGState()

        //vertical line from popup to bottom
        context.setLineWidth(1.0)
        context.setStrokeColor(UIColor.chartPopupLine.cgColor)
        context.move(to: CGPoint(x: pointX, y: Constants.popupTop))
        context.addLine(to: CGPoint(x: pointX, y: bounds.height))
        context.strokePath()

        context.restoreGState()
    }
}
