//
//  LineSelectionViewControllerDelegate.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import Foundation

protocol LineSelectionViewControllerDelegate: AnyObject {
    func didSelectLine(at index: Int)
}
