//
//  UIView.swift
//  TelegramLineChart
//
//  Created by Valentin Vafiadi
//  Copyright © 2019 Valentin Vafiadi. All rights reserved.
//

import UIKit

extension UIView {

    func setIsHiddenAnimated(_ isHidden: Bool,
                     animationDuration: TimeInterval = 0.2,
                     options: UIView.AnimationOptions = [.curveEaseOut, .beginFromCurrentState]) {

        UIView.animate(withDuration: animationDuration, delay: 0, options: options, animations: { [weak self] in
            if !isHidden {
                self?.isHidden = isHidden
            }
            self?.alpha = isHidden ? 0 : 1
        }, completion: { [weak self] _ in
            if isHidden {
                self?.isHidden = isHidden
            }
        })
    }
}