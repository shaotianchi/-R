//
//  Alert.swift
//  Я
//
//  Created by Shao Tianchi on 2018/2/20.
//  Copyright © 2018年 Shao Tianchi. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func toast(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        self.present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
}
