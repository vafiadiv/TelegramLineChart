//
//  PointPopupDrawer.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

internal struct PointPopupDrawer {

    private enum Constants {
        static let size = CGSize(width: 94, height: 40)

        static let lineHeight: CGFloat = 14

        static let cornerRadius: CGFloat = 3

        static let boldFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        static let lightFont = UIFont.systemFont(ofSize: 15, weight: .light)
    }

    var context: CGContext?

    func drawPopup(atTopCenter point: CGPoint, pointInfos: [ChartPopupPointInfo]) {
        guard let context = context, !pointInfos.isEmpty else {
            return
        }

/*
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short

        let date = Date(timeIntervalSince1970: TimeInterval(pointInfos[0].dataPoint.x))
        let dateString = formatter.string(from: date)
*/

        for pointInfo in pointInfos {

        }
        print("printing popup with values: \(pointInfos.map { $0.valueY }.joined(separator: ", "))")

        context.saveGState()

        let backgroundRect = CGRect(x: point.x - Constants.size.width / 2, y: point.y, width: Constants.size.width, height: Constants.size.height)
        let rectPath = CGPath(roundedRect: backgroundRect, cornerWidth: Constants.cornerRadius, cornerHeight: Constants.cornerRadius, transform: nil)

        context.setFillColor(UIColor.chartPopupBackground.cgColor)
        context.addPath(rectPath)
        context.fillPath()

        context.restoreGState()
    }
}
