//
//  Bitmap.swift
//  Engine
//
//  Created by K.Hatano on 2020/08/20.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

public struct Bitmap {
    public private(set) var pixcels: [Color]
    public let width: Int
    
    public init(width: Int, pixcels: [Color]) {
        self.width = width
        self.pixcels = pixcels
    }
}

public extension Bitmap {
    var height: Int {
        return pixcels.count / width
    }
    
    subscript(x: Int, y: Int) -> Color {
        get { return pixcels[y * width + x] }
        set { pixcels[y * width + x] = newValue }
    }
    
    init(width: Int, height: Int, color: Color) {
        self.pixcels = Array(repeating: color, count: width * height)
        self.width = width
    }
}
