//
//  CGSize.swift
//  ArtFit
//
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

extension CGSize {

	var ceiled: CGSize {
		return CGSize(width: ceil(self.width), height: ceil(self.height))
	}
}
