//
//  LineSelectionView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import UIKit

class LineSelectionView: UITableView {

    private enum Constants {

        static let rowHeight: CGFloat = 44
    }

    // MARK: - Public methods

    static func height(for numberOfRows: Int) -> CGFloat {
        return CGFloat(numberOfRows) * Constants.rowHeight - 1
    }

    // MARK: - Overrides

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let dataSource = dataSource else {
            return .zero
        }

        let numberOfRows = dataSource.tableView(self, numberOfRowsInSection: 0)
        return CGSize(width: size.width, height: type(of: self).height(for: numberOfRows))
    }
}
