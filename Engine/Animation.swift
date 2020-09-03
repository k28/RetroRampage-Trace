//
//  Animation.swift
//  Engine
//
//  Created by K.Hatano on 2020/09/04.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

public struct Animation {
    public let frames: [Texture]
    public let duration: Double
    public var time: Double = 0
    
    public init(frames: [Texture], duration: Double) {
        self.frames = frames
        self.duration = duration
    }
}

public extension Animation {
    var texture: Texture {
        guard duration > 0 else {
            return frames[0]
        }
        
        let t = time.truncatingRemainder(dividingBy: duration) / duration   // 不動小数点型の%の代わりのメソッド
        return frames[Int(Double(frames.count) * t)]
    }
}

