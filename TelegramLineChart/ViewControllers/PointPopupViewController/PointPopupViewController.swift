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

    //TODO: hidden flags
    var dataLines = [DataLine]()

    var dataLineHiddenFlags = [Bool]()

    // MARK: - Private properties

    private let linearFunctionFactory = LinearFunctionFactory<CGFloat>()

    private let dateFormatter = DateFormatter()

    // MARK: - Overrides

    override func loadView() {
        self.view = PointPopupView()
    }

    // MARK: - Public methods

    func setupWith(tapPoint: CGPoint, visibleDataRect: DataRect, chartRect: CGRect) {
        guard !dataLines.isEmpty, dataLines.count == dataLineHiddenFlags.count else {
            return
        }

        let unitMinX = CGFloat(visibleDataRect.origin.x)
        let unitMaxX = CGFloat(visibleDataRect.origin.x + visibleDataRect.width)

        let tapDataPointX = DataPoint.DataType(unitMinX + (unitMaxX - unitMinX) * tapPoint.x / chartRect.width)

        var pointInfos = [PointPopupView.PointInfo]()
        pointInfos.reserveCapacity(dataLines.count)

        for i in 0..<dataLines.count {
            let dataLine = dataLines[i]

            guard let leftPointUnit = dataLine.points.last(where: { $0.x < tapDataPointX }),
                  let rightPointUnit = dataLine.points.first(where: { $0.x > tapDataPointX }),
                  dataLineHiddenFlags[i] == false
                    else {
                continue
            }

            let function = linearFunctionFactory.function(
                    x1: CGFloat(leftPointUnit.x),
                    y1: CGFloat(leftPointUnit.y),
                    x2: CGFloat(rightPointUnit.x),
                    y2: CGFloat(rightPointUnit.y))

            let dataPointY = DataPoint.DataType(function(CGFloat(tapDataPointX)))

            let dataPoint = DataPoint(x: tapDataPointX, y: dataPointY)

            let graphPoint = dataPoint.convert(from: visibleDataRect, to: chartRect)

            pointInfos.append(PointPopupView.PointInfo(pointY: graphPoint.y, color: dataLine.color, valueY: String(dataPoint.y)))
        }

        let date = Date(timeIntervalSince1970: TimeInterval(tapDataPointX / 1000))

        dateFormatter.locale = Locale.current

        dateFormatter.dateFormat = "yyyy"
        let year = dateFormatter.string(from: date)

        dateFormatter.dateFormat = "MMM dd"
        let monthDay = dateFormatter.string(from: date)

        rootView.DTO = PointPopupView.DTO(monthDay: monthDay, year: year, pointInfos: pointInfos)
        rootView.setNeedsDisplay()
    }
}
