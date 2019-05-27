//
//  ChartPointsCalculator.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartPointsCalculator {

    static func points(from dataPoints: [DataPoint], in rect: CGRect, bottomLeftPoint: DataPoint, topRightPoint: DataPoint) -> [CGPoint] {

        let pointsPerUnitX = rect.width / CGFloat(topRightPoint.x - bottomLeftPoint.x)
        let pointsPerUnitY = rect.height / CGFloat(topRightPoint.y - bottomLeftPoint.y)

        return dataPoints.map { dataPoint in
            let unitRelativeX = CGFloat(dataPoint.x - bottomLeftPoint.x)
            let unitRelativeY = CGFloat(dataPoint.y - bottomLeftPoint.y)

            let screenPoint = CGPoint(
                    x: rect.origin.x + unitRelativeX * pointsPerUnitX,
                    y: rect.origin.y + rect.height - (unitRelativeY * pointsPerUnitY))
            return screenPoint
        }
//        for dataPoint in dataPoints {
//        }
    }
}
