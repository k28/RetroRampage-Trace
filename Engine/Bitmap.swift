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
    public let width, height: Int
    public let isOpaque: Bool
    
    public init(height: Int, pixcels: [Color]) {
        self.height = height
        self.width = pixcels.count / height
        self.pixcels = pixcels
        self.isOpaque = pixcels.allSatisfy { $0.isOpaque }
    }
}

public extension Bitmap {
    subscript(x: Int, y: Int) -> Color {
        get { return pixcels[x * height + y] }
        set {
            guard x >= 0, y >= 0, x < width, y < height else { return }
            pixcels[x * height + y] = newValue
        }
    }
    
    subscript(normalized x: Double, y: Double) -> Color {
        return self[Int(x * Double(width)), Int(y * Double(height))]
    }
    
    init(width: Int, height: Int, color: Color) {
        self.pixcels = Array(repeating: color, count: width * height)
        self.height = height
        self.width = width
        self.isOpaque = color.isOpaque
    }
    
    mutating func fill(rect: Rect, color: Color) {
        for x in Int(rect.min.x) ..< Int(rect.max.x) {
            for y in Int(rect.min.y) ..< Int(rect.max.y) {
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
    
    mutating func drawColumn(_ sourceX: Int, of source: Bitmap, at point: Vector, height: Double) {
        let start = Int(point.y), end = Int((point.y + height).rounded(.up))
        let stepY = Double(source.height) / height
        
        let offset = Int(point.x) * self.height
        if source.isOpaque {
            for y in max(0, start) ..< min(self.height, end) {
                let sourceY = max(0, Double(y) - point.y) * stepY
                let sourceColor = source[sourceX, Int(sourceY)]
                pixcels[offset + y] = sourceColor
            }
        } else {
            for y in max(0, start) ..< min(self.height, end) {
                let sourceY = max(0, Double(y) - point.y) * stepY
                let sourceColor = source[sourceX, Int(sourceY)]
                // 色を混ぜて描画する
                blendPixcel(at: offset + y, with: sourceColor)
            }
        }
    }
    
    mutating func drawImage(_ source: Bitmap, at point: Vector, size: Vector) {
        let start = Int(point.x), end = Int(point.x + size.x)
        let stepX = Double(source.width) / size.x
        for x in max(0, start) ..< min(width, end) {
            let sourceX = (Double(x) - point.x) * stepX
            let outputPosition = Vector(x: Double(x), y: point.y)
            drawColumn(Int(sourceX), of: source, at: outputPosition, height: size.y)
        }
    }
    
    private mutating func blendPixcel(at index: Int, with newColor: Color) {
        switch newColor.a {
        case 0:
            break
        case 255:
            pixcels[index] = newColor
        default:
            let oldColor = pixcels[index]
            let inverseAlpha = 1 - Double(newColor.a) / 255
            pixcels[index] = Color(
                r: UInt8(Double(oldColor.r) * inverseAlpha) + newColor.r,
                g: UInt8(Double(oldColor.g) * inverseAlpha) + newColor.g,
                b: UInt8(Double(oldColor.b) * inverseAlpha) + newColor.b
            )
        }
    }
    
    mutating func tint(with color: Color, opacity: Double) {
        let opacity = min(1, max(0, Double(color.a) / 255 * opacity))
        let color = Color(
            r: UInt8(opacity * Double(color.r)),
            g: UInt8(opacity * Double(color.g)),
            b: UInt8(opacity * Double(color.b)),
            a: UInt8(opacity * 255)
        )
        for i in pixcels.indices {
            blendPixcel(at: i, with: color)
        }
    }
}
