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

    fileprivate struct Mark {

        let label: String

        let unitX: DataPoint.DataType

        func labelCenterXFor(frameWidth: CGFloat, minUnitX: DataPoint.DataType, unitXWidth: DataPoint.DataType) -> CGFloat {
            return frameWidth * CGFloat(unitX - minUnitX) / CGFloat(unitXWidth)
        }
    }

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
            setNeedsLayout()
        }
    }

    // MARK: - Private properties

    private var marks = [Mark]()

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

    private var fadingInLabels = [UILabel]()

    // MARK: - Overrides

    override func layoutSubviews() {
        super.layoutSubviews()

        updateMarks()

        let currentUnitXs = (visibleLabels + fadingInLabels).compactMap { $0.mark?.unitX }
        let markUnitXs = marks.map { $0.unitX }

        //for detailed information about zooming algorithm see `updateMarks()`.

        //3 cases with different animations:

        //1. markUnitDistance increased, i.e. zoomed out past a threshold from the last call. Hide labels with fade out animation
        if markUnitDistance > previousMarkUnitDistance {

            for label in visibleLabels {
                if let mark = label.mark, !markUnitXs.contains(mark.unitX) {
                    //TODO: reuse, animation
                    fadingOutLabels.append(label)
                    UIView.animate(
                            withDuration: Constants.animationDuration,
                            animations: { label.alpha = 0 },
                            completion: { _ in
                                self.fadingOutLabels.removeAll { $0 == label }
                                label.removeFromSuperview()
                            })
                }
            }

            visibleLabels.removeAll { fadingOutLabels.contains($0) }

        } else if markUnitDistance < previousMarkUnitDistance {
        //2. markUnitDistance decreased, i.e. zoomed in past a threshold from in from the last call. Show new labels with fade in animation

            visibleLabels.removeAll {
                if let mark = $0.mark {
                    //TODO: reuse?
                    return !markUnitXs.contains(mark.unitX)
                } else {
                    return true
                }
            }

            var startAnimation = false

            for mark in marks {
                if !currentUnitXs.contains(mark.unitX) {
                    let label = popReusableLabel()
                    label.mark = mark
                    label.alpha = 0
                    fadingInLabels.append(label)
                    startAnimation = true
                }
            }

            if startAnimation {
                UIView.animate(
                        withDuration: Constants.animationDuration,
                        animations: { [weak self] in
                            self?.fadingInLabels.forEach {
                                $0.alpha = 1
                            }
                        },
                        completion: { [weak self] _ in
                            guard let self = self else {
                                return
                            }

                            self.visibleLabels.append(contentsOf: self.fadingInLabels)
                            self.fadingInLabels.removeAll()
                        })
            }
        } else {
        //3. markUnitDistance unchanged, remove/add labels without animation

            visibleLabels.removeAll {
                if let mark = $0.mark {
                    //TODO: reuse
                    return !markUnitXs.contains(mark.unitX)
                } else {
                    return true
                }
            }

            for mark in marks {
                if !currentUnitXs.contains(mark.unitX) {
                    let label = popReusableLabel()
                    label.mark = mark
                    visibleLabels.append(label)
                }
            }
        }

        let rangeWidth = visibleXRange.upperBound - visibleXRange.lowerBound
        let allLabels = visibleLabels + fadingInLabels + fadingOutLabels

        //set all labels into place (including ones that are animating)
        for label in allLabels {
            if let mark = label.mark {
                label.text = mark.label
                let labelCenterX = mark.labelCenterXFor(frameWidth: frame.width, minUnitX: visibleXRange.lowerBound, unitXWidth: rangeWidth)
                label.frame = CGRect(x: labelCenterX - maxLabelWidth / 2, y: 0, width: maxLabelWidth, height: bounds.height)
            }
        }
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

        guard rangeWidth != 0 else {
            //TODO: error
            return
        }

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

        marks = markUnitXs.map { [unowned self] markUnitX in
            let pointX = self.frame.width * CGFloat(markUnitX - self.visibleXRange.lowerBound) / rangeWidth
            //TODO: date string caching?
            let date = Date(dataPointX: markUnitX)
            return Mark(label: self.dateFormatter.string(from: date), unitX: markUnitX)
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

        //TODO: constants
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

extension UILabel {

    private enum AssociatedKeys {
        static var Mark = "mark_key"
    }

    fileprivate var mark: ChartDateIndicatorView.Mark? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.Mark) as? ChartDateIndicatorView.Mark
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.Mark, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}
