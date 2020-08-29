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
        set {
            guard x >= 0, y >= 0, x < width, y < height else { return }
            pixcels[y * width + x] = newValue
            
        }
    }
    
    init(width: Int, height: Int, color: Color) {
        self.pixcels = Array(repeating: color, count: width * height)
        self.width = width
    }
    
    mutating func fill(rect: Rect, color: Color) {
        for y in Int(rect.min.y) ..< Int(rect.max.y) {
            for x in Int(rect.min.x) ..< Int(rect.max.x) {
                self[x, y] = color
            }
        }
    }
    
    mutating func drawLine(from: Vector, to: Vector, color: Color) {
        let difference = to - from
        let stepCount: Int
        let step: Vector
        if abs(difference.x) > abs(difference.y) {
            stepCount = Int(abs(difference.x).rounded(.up))
            let sign = difference.x > 0 ? 1.0 : -1.0
            step = Vector(x: 1, y: difference.y / difference.x) * sign
        } else {
            stepCount = Int(abs(difference.y).rounded(.up))
            let sign = difference.y > 0 ? 1.0 : -1.0
            step = Vector(x: difference.x / difference.y, y: 1) * sign
        }
        
        var point = from
        for _ in 0 ..< stepCount {
            self[Int(point.x), Int(point.y)] = color
            point += step
        }
    }
}
