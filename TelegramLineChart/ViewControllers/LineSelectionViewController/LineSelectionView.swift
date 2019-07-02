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
        static let rowHeight: CGFloat = 44.0
    }

/*
    // MARK: - Initialization
    override init() {
        super.init(frame: .zero, style: .plain)
        rowHeight = Constants.rowHeight
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }
*/
    override var rowHeight: CGFloat {
        get {
            return 44.0
        }
        set {

        }
    }

    // MARK: - Public methods

    static func height(for numberOfRows: Int) -> CGFloat {
        return CGFloat(numberOfRows) * Constants.rowHeight
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
