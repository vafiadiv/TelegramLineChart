//
//  PointPopupView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import UIKit

class PointPopupView: UIView {

    //Data transfer object containing all info necessary for drawing

    struct DTO {
        var monthDay: String

        var year: String

        var pointInfos: [PointInfo]
    }

    struct PointInfo {

        var pointY: CGFloat

        var color: UIColor

        var valueY: String
    }

    private enum Constants {

        static let circleDiameter: CGFloat = 7

        static let lineWidth: CGFloat = 2

        static let popupTop: CGFloat = 5

        static let textOffset = UIOffset(horizontal: 10, vertical: 10)

        static let textLineHeight: CGFloat = 16

        static let textLineSpacing: CGFloat = 10

        static let dateToValuesHorizontal: CGFloat = 20

        static let popupCornerRadius: CGFloat = 4

        static let yearAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.pointPopupTextColor,
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]

        static let monthDayAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.pointPopupTextColor,
            .font: UIFont.systemFont(ofSize: 12, weight: .light)
        ]

        static let yValueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .medium)
        ]
    }

    // MARK: - Public properties

    var DTO: DTO? {
        didSet {
            if let DTO = self.DTO {
                updateSizes(with: DTO)
            }
        }
    }

    // MARK: - Private properties

    private var yearSize: CGSize = .zero

    private var monthDaySize: CGSize = .zero

    private var valueYSizes: [CGSize] = []

    private var popupSize: CGSize = .zero

    private var debugDrawing = true

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

        drawPopup(atTopCenter: CGPoint(x: bounds.center.x, y: Constants.popupTop), DTO: DTO, context: context, rect: rect)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: popupSize.width, height: size.height)
    }

    // MARK: - Private methods

    private func updateSizes(with DTO: DTO) {
        monthDaySize = NSString(string: DTO.monthDay).size(withAttributes: Constants.monthDayAttributes)

        yearSize = NSString(string: DTO.year).size(withAttributes: Constants.yearAttributes)

        valueYSizes = DTO.pointInfos.map { NSString(string: $0.valueY).size(withAttributes: Constants.yValueAttributes) }

        let valueYWidths = valueYSizes.map { $0.width }

        let popupWidth = Constants.textOffset.horizontal * 2 +
                max(yearSize.width, monthDaySize.width) +
                Constants.dateToValuesHorizontal +
                (valueYWidths.max() ?? 0)

        let popupHeight = Constants.textOffset.vertical * 2 +
                CGFloat(max(2, valueYSizes.count)) * Constants.textLineHeight -
                Constants.textLineSpacing

        popupSize = CGSize(width: popupWidth, height: popupHeight)
    }

    //vertical line from popup to bottom
    private func drawVerticalLine(at pointX: CGFloat, to context: CGContext) {

        context.saveGState()

        context.setLineWidth(1.0)
        context.setStrokeColor(UIColor.chartPopupLine.cgColor)
        context.move(to: CGPoint(x: pointX, y: Constants.popupTop))
        context.addLine(to: CGPoint(x: pointX, y: bounds.height))
        context.strokePath()

        context.restoreGState()
    }

    func drawPopup(atTopCenter point: CGPoint, DTO: DTO, context: CGContext, rect: CGRect) {
        context.saveGState()

        let backgroundRect = CGRect(x: point.x - popupSize.width / 2, y: point.y, width: popupSize.width, height: popupSize.height)
        let rectPath = CGPath(roundedRect: backgroundRect, cornerWidth: Constants.popupCornerRadius, cornerHeight: Constants.popupCornerRadius, transform: nil)

        context.setFillColor(UIColor.chartPopupBackground.cgColor)
        context.addPath(rectPath)
        context.fillPath()

        NSString(string: DTO.monthDay).draw(
                at: CGPoint(x: Constants.textOffset.horizontal, y: Constants.textOffset.vertical),
                withAttributes: Constants.yearAttributes)
        NSString(string: DTO.year).draw(
                at: CGPoint(x: Constants.textOffset.horizontal, y: Constants.textOffset.vertical + Constants.textLineHeight),
                withAttributes: Constants.monthDayAttributes)

        var attributes = Constants.yValueAttributes
        for i in 0..<DTO.pointInfos.count {
            let pointInfo = DTO.pointInfos[i]
            attributes[NSAttributedString.Key.foregroundColor] = pointInfo.color
            let point = CGPoint(
                    x: rect.width - Constants.textOffset.horizontal - valueYSizes[i].width,
                    y: Constants.textOffset.vertical + Constants.textLineHeight * CGFloat(i))
            NSString(string: pointInfo.valueY).draw(at: point, withAttributes: attributes)
        }

        context.restoreGState()

    }
}
