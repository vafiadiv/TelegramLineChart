//
//  ChartLayer.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi on 17/03/2019.
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartLayer: CALayer {

	var border = CGSize(width: 10, height: 10)

	var dataLine: DataLine?

	override func draw(in ctx: CGContext) {
		super.draw(in: ctx)
	}
}
