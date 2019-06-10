//
//  ChartDateIndicatorView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartDateIndicatorView: UIView {

    private enum Constants {
        static let tmpMaxLabels: CGFloat = 7 //TODO: calculate as (view width / label width)
        static let millisecondsInDay: CGFloat = 1000 * 60 * 60 * 24
    }

    private var marks = [(x: CGFloat, label: String)]()

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        return dateFormatter
    }()
/*
    var dates = [(relativeX: Double, dateString: String)]() {
        didSet {
            setNeedsDisplay()
        }
    }
*/

    var totalXRange: ClosedRange<DataPoint.DataType>? {
        didSet {
            setNeedsDisplay()
        }
    }

    var visibleXRange: ClosedRange<DataPoint.DataType> = 0...0 {
        didSet {
//3 массива: visibleLabels, hiddenLabels, reusableLabels. Метод dequeueLabel() -> UILabel
//На каждый set xRange:
//Надо понять,
//  1. (опционально) если visibleLabels.count и hiddenLabels.count < нужного кол-ва - добавляем лейблы до нужного кол-ва;
//  2. Проверяем, надо ли добавлять видимые лейблы (zoom in):
            updateMarks()
            setNeedsDisplay()
        }
    }

    private func updateMarks() {
        let rangeWidth = CGFloat(visibleXRange.upperBound - visibleXRange.lowerBound)
        let numberOfDivisions = ceil(log2(rangeWidth / (Constants.millisecondsInDay * Constants.tmpMaxLabels)))

        let markUnitDistance = Constants.millisecondsInDay * pow(2, numberOfDivisions)
        let firstMarkUnitX = DataPoint.DataType(floor(CGFloat(visibleXRange.lowerBound) / markUnitDistance) * markUnitDistance)
        let lastMarkUnitX = DataPoint.DataType(ceil(CGFloat(visibleXRange.upperBound) / markUnitDistance) * markUnitDistance)
        let markUnitXs = stride(from: firstMarkUnitX, through: lastMarkUnitX, by: DataPoint.DataType(markUnitDistance))

        marks = markUnitXs.map { [unowned self] markUnitX in
            let pointX = self.frame.width * CGFloat(markUnitX - self.visibleXRange.lowerBound) / rangeWidth
            //TODO: date string caching
            let date = Date(dataPointX: markUnitX)
            return (x: pointX, label: self.dateFormatter.string(from: date))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateMarks()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.setStrokeColor(UIColor.chartHorizontalLines.cgColor)
        context.setLineWidth(2)

        let tmpTextWidth: CGFloat = 40

        let tmpAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.pointPopupTextColor,
            .font: UIFont.systemFont(ofSize: 12, weight: .light)
        ]


        marks.forEach { x, dateString in
            context.move(to: CGPoint(x: x, y: bounds.minY))
            context.addLine(to: CGPoint(x: x, y: bounds.maxY))
            NSString(string: dateString).draw(in: CGRect(center: CGPoint(x: x, y: bounds.midY), width: tmpTextWidth, height: bounds.height), withAttributes: tmpAttributes)
        }

        context.strokePath()
    }
}
