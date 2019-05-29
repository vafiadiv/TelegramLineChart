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
        static let size = CGSize(width: 94, height: 60)
        static let cornerRadius: CGFloat = 3
    }

    var context: CGContext?

    func drawPopup(atTopCenter point: CGPoint) {
        guard let context = context else {
            return
        }

        context.saveGState()

        let backgroundRect = CGRect(x: point.x - Constants.size.width / 2, y: point.y, width: Constants.size.width, height: Constants.size.height)
        let rectPath = CGPath(roundedRect: backgroundRect, cornerWidth: Constants.cornerRadius, cornerHeight: Constants.cornerRadius, transform: nil)

        context.setFillColor(UIColor.chartPopupBackground.cgColor)
        context.addPath(rectPath)
        context.fillPath()

        context.restoreGState()
    }
}
