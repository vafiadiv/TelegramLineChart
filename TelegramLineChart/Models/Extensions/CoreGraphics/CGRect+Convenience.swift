//
//  CGRect+Convenience.swift
//  TelegramLineChart
//
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

extension CGRect {
    var x: CGFloat {
        return self.origin.x
    }
    
    var y: CGFloat {
        return self.origin.y
    }

	var ceiled: CGRect {
		return CGRect(origin: self.origin.ceiled, size: self.size.ceiled)
	}

    var center: CGPoint {
        return CGPoint(x: self.midX, y: self.midY)
    }

    init(width: CGFloat, height: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: height)
    }
}
