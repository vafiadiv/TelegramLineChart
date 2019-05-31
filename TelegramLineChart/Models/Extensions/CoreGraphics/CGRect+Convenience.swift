//
//  CGRect+Convenience.swift
//  TelegramLineChart
//
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

extension CGRect {

    // MARK: - Rect dimensions access

    var x: CGFloat {
        get {
            return self.origin.x
        }
        set {
            self.origin.x = newValue
        }
    }

    var y: CGFloat {
        get {
            return self.origin.y
        }
        set {
            self.origin.y = newValue
        }
    }

    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }

    // MARK: - Other

    var ceiled: CGRect {
        return CGRect(origin: self.origin.ceiled, size: self.size.ceiled)
    }

    init(width: CGFloat, height: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: height)
    }

    init(center: CGPoint, size: CGSize) {
        self.init(origin: CGPoint(x: center.x - size.width / 2, y: center.y - size.height / 2), size: size)
    }

    init(center: CGPoint, width: CGFloat, height: CGFloat) {
        self.init(origin: CGPoint(x: center.x - width / 2, y: center.y - height / 2), size: CGSize(width: width, height: height))
    }
}
