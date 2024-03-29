//
//  LineRangeSelectionViewControllerDelegate.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import Foundation

protocol LineRangeSelectionViewControllerDelegate: AnyObject {
    func didSelectChartPartition(minUnitX: DataPoint.DataType, maxUnitX: DataPoint.DataType)
}
