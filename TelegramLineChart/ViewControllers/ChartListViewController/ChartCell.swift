//
//  ChartCell.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartCell: UITableViewCell {

    var hostedView: UIView? {
        didSet {
            if let hostedView = hostedView {
                contentView.addSubview(hostedView)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.hostedView?.removeFromSuperview()
        self.hostedView = nil
    }
}
