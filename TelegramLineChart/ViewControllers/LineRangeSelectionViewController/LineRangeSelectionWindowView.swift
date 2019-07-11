//
//  ChartSelectWindowView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import UIKit

class LineRangeSelectionWindowView: UIView {

    private enum Constants {
        static let sideViewWidth: CGFloat = 11
    }

    // MARK: - Public properties

    var isLeftHighlighted = false {
        didSet {
            self.leftSideView.backgroundColor = isLeftHighlighted ? .selectionWindowBackgroundHighlighted : .selectionWindowBackground
        }
    }

    var isRightHighlighted = false {
        didSet {
            self.rightSideView.backgroundColor = isRightHighlighted ? .selectionWindowBackgroundHighlighted : .selectionWindowBackground
        }
    }

    // MARK: - Private properties

    private let leftSideView = LineRangeSelectionWindowSideView(orientation: .left)
    private let rightSideView = LineRangeSelectionWindowSideView(orientation: .right)

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        leftSideView.backgroundColor = .selectionWindowBackground
        rightSideView.backgroundColor = .selectionWindowBackground
        addSubview(leftSideView)
        addSubview(rightSideView)
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.saveGState()

        context.setStrokeColor(UIColor.selectionWindowBackground.cgColor)

        //two lines at the top and bottom between side views
        let path = UIBezierPath()
        path.lineWidth = 2.0
        path.move(to: CGPoint(x: Constants.sideViewWidth, y: 0))
        path.addLine(to: CGPoint(x: bounds.width - Constants.sideViewWidth, y: 0))
        path.move(to: CGPoint(x: Constants.sideViewWidth, y: bounds.height))
        path.addLine(to: CGPoint(x: bounds.width - Constants.sideViewWidth, y: bounds.height))
        path.stroke()

        context.restoreGState()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        leftSideView.frame = CGRect(x: 0, y: 0, width: Constants.sideViewWidth, height: bounds.height)
        rightSideView.frame = CGRect(x: bounds.width - Constants.sideViewWidth, y: 0, width: Constants.sideViewWidth, height: bounds.height)
        setNeedsDisplay()
    }
}

fileprivate class LineRangeSelectionWindowSideView: UIView {

    enum Orientation {
        case left
        case right
    }

    private let arrowImageView = UIImageView(image: .leftArrowImage)

    init(orientation: Orientation) {

        super.init(frame: .zero)

        addSubview(arrowImageView)

        layer.masksToBounds = true
        layer.cornerRadius = 2

        switch orientation {
        case .left:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .right:
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
            arrowImageView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        arrowImageView.sizeToFit()
        arrowImageView.center = bounds.center
    }
}
