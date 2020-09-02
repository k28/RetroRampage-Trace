//
//  UIImage+Bitmap.swift
//  RetroRampage
//
//  Created by K.Hatano on 2020/08/21.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import UIKit
import Engine 

extension UIImage {
    convenience init?(bitmap: Bitmap) {
        let alphaInfo = CGImageAlphaInfo.premultipliedLast
        let bytesPerPixcel = MemoryLayout<Color>.size
        let bytesPerRow = bitmap.width * bytesPerPixcel
        
        let data = Data(bytes: bitmap.pixcels, count: bitmap.height * bytesPerRow)
        guard let providerRef = CGDataProvider(data: data as CFData) else {
            return nil
        }
        
        guard let cgImage = CGImage(
            width: bitmap.width,
            height: bitmap.height,
            bitsPerComponent: 8,
            bitsPerPixel: bytesPerPixcel * 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo(rawValue: alphaInfo.rawValue),
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
            ) else {
                return nil
        }
        
        self.init(cgImage: cgImage)        
    }
}

extension Bitmap {
    init?(image: UIImage) {
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        let alphaInfo = CGImageAlphaInfo.premultipliedLast
        let bytesPerPixcel = MemoryLayout<Color>.size
        let bytesPerRow = cgImage.width * bytesPerPixcel
        
        var pixcels = [Color](repeating: .clear, count: cgImage.width * cgImage.height)
        guard let context = CGContext(data: &pixcels,
                                      width: cgImage.width,
                                      height: cgImage.height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: alphaInfo.rawValue
            ) else {
                return nil
        }
        
        context.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
        self.init(width: cgImage.width, pixcels: pixcels)
    }
}
