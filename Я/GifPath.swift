//
//  GifPath.swift
//  Я
//
//  Created by Shao Tianchi on 2018/2/20.
//  Copyright © 2018年 Shao Tianchi. All rights reserved.
//

import Foundation

let home = NSHomeDirectory()
private extension String {
    init(documents path: String) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? ""
        self.init("\(documents)/\(path)")
    }
}

struct GifPath {
    static let origin = String(documents: "origin.gif")
    static let reversed = String(documents: "reversed.gif")
}
