//
//  ChartPointsCalculator.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import UIKit

class ChartPointsCalculator {

    static func points(from dataPoints: [DataPoint], in rect: CGRect, bottomLeftPoint: DataPoint, pointsPerUnitX: CGFloat, pointsPerUnitY: CGFloat) -> [CGPoint] {

        return dataPoints.map { dataPoint in
            let unitRelativeX = CGFloat(dataPoint.x - bottomLeftPoint.x)
            let unitRelativeY = CGFloat(dataPoint.y - bottomLeftPoint.y)

            let screenPoint = CGPoint(
                    x: rect.origin.x + unitRelativeX * pointsPerUnitX,
                    y: rect.origin.y + rect.height - (unitRelativeY * pointsPerUnitY))
            return screenPoint
        }
    }
}
