//
//  PointPopupController.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit


class PointPopupViewController: UIViewController, RootViewProtocol {

    typealias RootViewType = PointPopupView

    // MARK: - Public properties

//    var chartRect: CGRect?
//
//    var dataRect: DataRect?

    var dataLines: [DataLine]?

    // MARK: - Private properties

    private let linearFunctionFactory = LinearFunctionFactory<CGFloat>()

    private let dateFormatter = DateFormatter()

    // MARK: - Overrides

    override func loadView() {
        self.view = PointPopupView()
    }

    // MARK: - Public methods

    func setupWith(tapPoint: CGPoint, visibleDataRect: DataRect, chartRect: CGRect) {
        guard let dataLines = dataLines else {
            return
        }

        let unitMinX = CGFloat(visibleDataRect.origin.x)
        let unitMaxX = CGFloat(visibleDataRect.origin.x + visibleDataRect.width)

        let tapDataPointX = DataPoint.DataType(unitMinX + (unitMaxX - unitMinX) * tapPoint.x / chartRect.width)

        let pointInfos: [PointPopupView.PointInfo] = dataLines.compactMap { dataLine in
            guard let leftPointUnit = dataLine.points.last(where: { $0.x < tapDataPointX }),
                  let rightPointUnit = dataLine.points.first(where: { $0.x > tapDataPointX }) else {
                return nil
            }

            let function = linearFunctionFactory.function(
                    x1: CGFloat(leftPointUnit.x),
                    y1: CGFloat(leftPointUnit.y),
                    x2: CGFloat(rightPointUnit.x),
                    y2: CGFloat(rightPointUnit.y))

            let dataPointY = DataPoint.DataType(function(CGFloat(tapDataPointX)))

            let dataPoint = DataPoint(x: tapDataPointX, y: dataPointY)

            let graphPoint = dataPoint.convert(from: visibleDataRect, to: chartRect)

            return PointPopupView.PointInfo(pointY: graphPoint.y, color: dataLine.color, valueY: String(dataPoint.y))
        }

        let date = Date(timeIntervalSince1970: TimeInterval(tapDataPointX / 1000))

        dateFormatter.locale = Locale.current

        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)

        dateFormatter.dateFormat = "MMM dd"
        let monthDay = dateFormatter.string(from: date)

        rootView.DTO = PointPopupView.DTO(monthDay: monthDay, year: year, pointInfos: pointInfos)
        rootView.DTO = PointPopupView.DTO(monthDay: monthDay, year: year, pointInfos: pointInfos)
        rootView.setNeedsDisplay()
    }
}
