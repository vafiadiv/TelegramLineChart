//
//  CGSize.swift
//  ArtFit
//
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

extension CGPoint {

	var ceiled: CGPoint {
		return CGPoint(x: ceil(self.x), y: ceil(self.y))
	}
}
