//
//  Rect.swift
//  Engine
//
//  Created by K.Hatano on 2020/08/22.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

public struct Rect {
    var min, max: Vector
    
    public init(min: Vector, max: Vector) {
        self.min = min
        self.max = max
    }
}
