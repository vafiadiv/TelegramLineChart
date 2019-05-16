//
//  ChartSelectWindowView.swift
//  ArtFit
//
//  Created by Valentin Vafiadi on 2019-05-15.
//  Copyright © 2019 VFD. All rights reserved.
//

import UIKit

class ChartSelectWindowView: UIView {

    // MARK: - Private properties

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 3
        layer.borderColor = UIColor.gray.cgColor
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }


}

fileprivate class ChartSelectWindowSideView: UIView {

    private enum Constants {
        static let leftArrowImage = #imageLiteral(resourceName: "chart_selection_window_arrow")
    }

    enum Orientation {
        case left
        case right
    }

    private var imageView: UIImageView
    
    init(orientation: Orientation) {
        imageView = UIImageView(image: Constants.leftArrowImage)

        super.init(frame: .zero)

        backgroundColor = UIColor(named: "selectionWindow")
        
        self.addSubview(imageView)
        layer.masksToBounds = true
        switch orientation {
        case .left:
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        case .right:
            layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }

    required init?(coder aDecoder: NSCoder) {
        notImplemented()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
