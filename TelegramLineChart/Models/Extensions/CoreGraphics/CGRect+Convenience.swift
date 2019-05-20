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

    var left: CGFloat {
        return self.origin.x
    }

    var right: CGFloat {
        return self.maxX
    }

    var top: CGFloat {
        return self.origin.y
    }

    var bottom: CGFloat {
        return maxY
    }

    // MARK: - Other

    var ceiled: CGRect {
        return CGRect(origin: self.origin.ceiled, size: self.size.ceiled)
    }

    init(width: CGFloat, height: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: height)
    }
}
