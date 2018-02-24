//
//  Color.swift
//  Я
//
//  Created by Shao Tianchi on 2018/2/20.
//  Copyright © 2018年 Shao Tianchi. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1) {
        let red     = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green   = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue    = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
