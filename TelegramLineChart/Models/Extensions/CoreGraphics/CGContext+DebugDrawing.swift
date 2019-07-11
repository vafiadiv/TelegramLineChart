//
//  CGContext.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import UIKit

extension CGContext {

    func debugPaintClippingRect() {

        saveGState()

        setStrokeColor(UIColor.brown.cgColor)
        setLineWidth(4)
        stroke(boundingBoxOfClipPath)
        setFillColor(UIColor.red.withAlphaComponent(0.2).cgColor)
        fill(boundingBoxOfClipPath)

        restoreGState()
    }
}