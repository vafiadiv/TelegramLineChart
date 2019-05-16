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
        return self.origin.x
    }

    var y: CGFloat {
        return self.origin.y
    }

    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }

    var left: CGFloat {
        return self.origin.x
    }

    var right: CGFloat {
        return self.origin.x + self.width
    }

    var top: CGFloat {
        return self.origin.y
    }

    var bottom: CGFloat {
        return self.origin.y + self.height
    }

    // MARK: - Other

    var ceiled: CGRect {
        return CGRect(origin: self.origin.ceiled, size: self.size.ceiled)
    }

    init(width: CGFloat, height: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: height)
    }
}
