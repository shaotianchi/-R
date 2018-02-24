//
//  Image.swift
//  Я
//
//  Created by Shao Tianchi on 2018/2/20.
//  Copyright © 2018年 Shao Tianchi. All rights reserved.
//

import UIKit
import MobileCoreServices
import ImageIO

extension UIImage {
    class func from(color: UIColor) -> UIImage? {
        let rect = CGRect(x:0, y:0, width:1, height:1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func saveTo(_ path: String) {
        let kFrameCount = self.images?.count ?? 0;
        
        let fileProperties = [
            kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: 0]
        ]
        
        let frameProperties = [
            kCGImagePropertyGIFDictionary as String: [
                kCGImagePropertyGIFDelayTime as String: Float(0.08)
            ]
        ]
        let fileURL = URL(fileURLWithPath: path)
        
        guard let destination = CGImageDestinationCreateWithURL(fileURL as CFURL, kUTTypeGIF, kFrameCount, nil) else {
            print("destination is nil")
            return
        }
        CGImageDestinationSetProperties(destination, fileProperties as CFDictionary);
        
        images?.forEach({ (image) in
            CGImageDestinationAddImage(destination, image.cgImage!, frameProperties as CFDictionary);
        })
        
        if (!CGImageDestinationFinalize(destination)) {
            print("failed to finalize image destination")
        }
    }
}
