//
//  Easing.swift
//  Engine
//
//  Created by K.Hatano on 2020/09/27.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

public enum Easing {}

public extension Easing {
    static func liner(_ t: Double) -> Double {
        return t
    }
    
    static func easeIn(_ t: Double) -> Double {
        return t * t
    }
    
    static func easeOut(_ t: Double) -> Double {
        return 1 - easeIn(1 - t)
    }
    
    static func easeInEaseOut(_ t: Double) -> Double {
        if t < 0.5 {
            return 2 * easeIn(t)
        } else {
            return 4 * t - 2 * easeIn(t) - 1
        }
    }
}
