//
//  ChartCell.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartCell: UITableViewCell {

    // MARK: - Initialization

    override init(style: CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }

    // MARK: - Overrides

    override func prepareForReuse() {
        super.prepareForReuse()
        self.hostedView?.removeFromSuperview()
        self.hostedView = nil
    }

    // MARK: - Public methods

    var hostedView: UIView? {
        didSet {
            if let hostedView = hostedView {
                hostedView.translatesAutoresizingMaskIntoConstraints = false
                hostedView.frame = self.contentView.bounds
                contentView.addSubview(hostedView)
            }
        }
    }
}
