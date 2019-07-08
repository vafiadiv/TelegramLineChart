//
//  LineSelectionView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class LineSelectionView: UITableView {

    private enum Constants {
        static let rowHeight: CGFloat = 44

        static let separatorHeight: CGFloat = 1
    }

    //TODO: comment for why this workaround is needed or remove it (нужно знать rowHeight в static-методе, поэтому либо копипастить константу,
    //либо перегружать init
    override var rowHeight: CGFloat {
        get {
            return Constants.rowHeight
        }
        set {

        }
    }

    // MARK: - Public methods

    static func height(for numberOfRows: Int) -> CGFloat {
        return CGFloat(numberOfRows) * (Constants.rowHeight + Constants.separatorHeight)
    }

    // MARK: - Overrides

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let delegate = delegate, let dataSource = dataSource else {
            return .zero
        }

        let numberOfRows = dataSource.tableView(self, numberOfRowsInSection: 0)
        return CGSize(width: size.width, height: type(of: self).height(for: numberOfRows))
    }
}
