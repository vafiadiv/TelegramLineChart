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
}
