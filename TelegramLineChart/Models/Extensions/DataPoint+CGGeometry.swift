//
//  DataPoint.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

extension DataPoint {

    func convert(from dataRect: DataRect, to rect: CGRect) -> CGPoint {

        let relativeX = CGFloat(self.x - dataRect.origin.x) / CGFloat(dataRect.width)
        //Since graph Y axis points up and in iOS Core Graphics Y axis points down, relativeY is calculated from the top
        let relativeY = CGFloat(dataRect.height + dataRect.origin.y - self.y) / CGFloat(dataRect.height)

        return CGPoint(
                x: rect.x + rect.width * relativeX,
                y: rect.y + rect.height * relativeY)
    }
}