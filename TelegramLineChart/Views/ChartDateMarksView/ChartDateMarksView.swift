//
//  ChartDateIndicatorView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartDateIndicatorView: UIView {

    // MARK: -

    private typealias Mark = (x: CGFloat, label: String, unitX: DataPoint.DataType)

    private enum Constants {
        static let millisecondsInDay: CGFloat = 1000 * 60 * 60 * 24

        static let textColor: UIColor = .chartHorizontalLinesText

        static let font = UIFont.systemFont(ofSize: 12, weight: .light)

        static let labelOffset: CGFloat = 10

        static let animationDuration: TimeInterval = 0.5
    }

    // MARK: - Public properties

    var visibleXRange: ClosedRange<DataPoint.DataType> = 0...0 {
        didSet {
//3 массива: visibleLabels, hiddenLabels, reusableLabels. Метод dequeueLabel() -> UILabel
//На каждый set xRange:
//Надо понять,
//  1. (опционально) если visibleLabels.count и hiddenLabels.count < нужного кол-ва - добавляем лейблы до нужного кол-ва;
//  2. Проверяем, надо ли добавлять видимые лейблы (zoom in):
            setNeedsDisplay()
            setNeedsLayout()
        }
    }

    // MARK: - Private properties

    private var marks = [Mark]()

    private var previousMarks = [Mark]()

    private var markUnitDistance: CGFloat = 0

    private var previousMarkUnitDistance: CGFloat = 0

    private lazy var maxLabelWidth: CGFloat = maxLabelSize().width

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        return dateFormatter
    }()

    private var maxMarks: CGFloat = 0

    private var reusableLabels = Stack<UILabel>()

    private var visibleLabels = [UILabel]()

    private var fadingOutLabels = [UILabel]()

    private var fadingOutMarks = [Mark]()

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()

        updateMarks()

/*
        let markUnitXs = marks.map { $0.unitX }
        let previousMarkUnitXs = previousMarks.map { $0.unitX }

        if markUnitDistance > previousMarkUnitDistance {
        }
        for (unitX, i) in markUnitXs.enumerated() {

        }
*/

        //add more visibleLabels if necessary
        while visibleLabels.count < marks.count {
            visibleLabels.append(popReusableLabel())
        }

        //remove visibleLabels if necessary
        while visibleLabels.count > marks.count, !visibleLabels.isEmpty {
            let label = visibleLabels[visibleLabels.count - 1]
            visibleLabels.removeLast()
            pushReusableLabel(label)
        }

        guard visibleLabels.count == marks.count else {
            print("")
            return
        }

        //set all visible labels into place
        for i in 0..<visibleLabels.count {
            let label = visibleLabels[i]
            let mark = marks[i]
            label.text = mark.label
            label.frame = CGRect(x: mark.x - maxLabelWidth / 2, y: 0, width: maxLabelWidth, height: bounds.height)
        }

        //1. запомнили текущее значение масштаба (или расст. между отметками) и отметки - текущее и предыдущее.
        //   markUnitDistance, previousMarkUnitDistance, marks, previousMarks
        //2. если не изменилось расстояние - делаем чтоб кол-во лейблов == кол-во отметок, проставляем лейблам тексты
        //3. Если увеличилось (zoom out) - надо спрятать лейблы. Как определить, какие прятать? Пробегаться по marks?
        //4. Если уменьшилось (zoom in) - надо показать лейблы. Как определить, на каких метках должны стоять прошлые, а
        //   на какие нужно добавить с fade in?

        //zoomed out between redraws - hide labels
        if markUnitDistance > previousMarkUnitDistance {
            //1. найти, какие пропали
            //2. добавить для них лейблы в hiddenLabels
            //3. скрыть с анимацией
        } else if markUnitDistance < previousMarkUnitDistance {
            //zoomed in between redraws - show labels
            //1. найти, на каких позициях появились - те, которых не было в previous
            //2. создать для них лейблы с альфа = 0, добавить в visible
            //3. проиграть анимацию альфа = 1

            let previousMarkUnitXs = previousMarks.map { $0.unitX }

            var fadeInLabels = [UILabel]()
            for i in 0..<marks.count {
                //find marks that were not visible in the previous redraw
                if !previousMarkUnitXs.contains(marks[i].unitX) {
                    let label = visibleLabels[i]
                    label.alpha = 0
                    fadeInLabels.append(label)
                }
            }

            UIView.animate(withDuration: Constants.animationDuration) {
                fadeInLabels.forEach { $0.alpha = 1 }
            }

            print()
        } else {
            //zoom unchanged, adding/removing all labels without animation
        }



        //TODO: tmp below
        let markXs = marks.map { $0.unitX }
        let prevMarkXs = previousMarks.map { $0.unitX }

        var newMarks = 0
        markXs.forEach {
            if !prevMarkXs.contains($0) {
                newMarks += 1
            }
        }
        if newMarks != 0 {
            print("\(newMarks) newMarks" + (previousMarkUnitDistance != markUnitDistance ? " AND mUD changed" : ""))
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.setStrokeColor(UIColor.red.withAlphaComponent(0.5).cgColor)
        context.setLineWidth(1)

        let tmpTextWidth: CGFloat = 50

        let tmpAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.pointPopupTextColor,
            .font: UIFont.systemFont(ofSize: 12, weight: .light)
        ]

        marks.forEach { x, dateString, _ in
/*
            context.move(to: CGPoint(x: x, y: bounds.minY))
            context.addLine(to: CGPoint(x: x, y: bounds.maxY))
            let tmpNumberFormatter = NumberFormatter()
            tmpNumberFormatter.maximumFractionDigits = 2
            NSString(string: tmpNumberFormatter.string(for: x)!).draw(in: CGRect(center: CGPoint(x: x, y: bounds.midY), width: tmpTextWidth, height: bounds.height), withAttributes: tmpAttributes)
*/
        }

        context.strokePath()
    }

    // MARK: - Private methods

    private func updateMarks() {
        //The view has to display a mark for each day, but when zooming too far out, there are too many marks to display.
        //To achieve correct zooming and panning of the dates view, the following algorithm is used:

        //1. Determine, how many marks can be displayed;
        maxMarks = floor(bounds.width / maxLabelWidth)

        //2. Thin out the day marks by removing every 2nd mark enough times so that number of marks inside `visibleXRange` < `maxMarks`,
        //   i.e. find `numberOfDivisions` - how many times do we have to divide the number of marks by 2 to get to `maxMarks`;
        let rangeWidth = CGFloat(visibleXRange.upperBound - visibleXRange.lowerBound)

        let numberOfDivisions = ceil(log2(rangeWidth / (Constants.millisecondsInDay * maxMarks)))

        //3. Find the distance between marks after thinning out;
        previousMarkUnitDistance = markUnitDistance

        markUnitDistance = Constants.millisecondsInDay * pow(2, numberOfDivisions)

        //4. Find the 1st and last mark near `visibleXRange` after the thinning out: `firstMarkUnitX`, `lastMarkUnitX`;
        //   Note: first and last marks can be outside of `visibleXRange`; that's intentional to allow edge labels to be
        //   partially visible
        let firstMarkUnitX = DataPoint.DataType(floor(CGFloat(visibleXRange.lowerBound) / markUnitDistance) * markUnitDistance)
        let lastMarkUnitX = DataPoint.DataType(ceil(CGFloat(visibleXRange.upperBound) / markUnitDistance) * markUnitDistance)

        //5. Find all visible mark values by striding from first to last.
        let markUnitXs = stride(from: firstMarkUnitX, through: lastMarkUnitX, by: DataPoint.DataType(markUnitDistance))

        if previousMarkUnitDistance != markUnitDistance {
            previousMarks = marks
        }

        marks = markUnitXs.map { [unowned self] markUnitX in
            let pointX = self.frame.width * CGFloat(markUnitX - self.visibleXRange.lowerBound) / rangeWidth
            //TODO: date string caching?
            let date = Date(dataPointX: markUnitX)
            return (x: pointX, label: self.dateFormatter.string(from: date), unitX: markUnitX)
        }
    }

    private func popReusableLabel() -> UILabel {
        if let label = reusableLabels.pop() {
            addSubview(label)
            return label
        } else {
            let label = UILabel()
            label.textColor = Constants.textColor
            label.font = Constants.font
            addSubview(label)
            return label
        }
    }

    private func pushReusableLabel(_ label: UILabel) {
        label.removeFromSuperview()
        reusableLabels.push(label)
    }

    //Calculates max label size across all month names.
    //Might not work correctly in locales with different digit text sizes
    private func maxLabelSize() -> CGSize {
        let attributes = [
            NSAttributedString.Key.foregroundColor: Constants.textColor,
            NSAttributedString.Key.font: Constants.font,
        ]

        let dayWithMaxTextWidth = 30

        var maxSize: CGSize = .zero
        var dateComponents = DateComponents(calendar: Calendar.current, year: 2019, day: dayWithMaxTextWidth)

        for i in 0..<12 {
            dateComponents.month = i
            if let date = dateComponents.date {
                let dateString = dateFormatter.string(from: date)

                let textSize = NSString(string: dateString).size(withAttributes: attributes)

                if maxSize.width < textSize.width {
                    maxSize = textSize
                }
            }
        }

        return CGSize(width: maxSize.width + Constants.labelOffset, height: maxSize.height).ceiled
    }
}
