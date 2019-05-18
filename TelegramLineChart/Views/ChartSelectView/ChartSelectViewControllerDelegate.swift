//
//  ChartSelectViewControllerDelegate.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import Foundation

protocol ChartSelectViewControllerDelegate: AnyObject {
    func didSelectChartPartition(minUnitX: DataPoint.XType, maxUnitX: DataPoint.XType)
}
