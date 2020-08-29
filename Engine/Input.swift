//
//  Input.swift
//  Engine
//
//  Created by K.Hatano on 2020/08/23.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

public struct Input {
    public var speed: Double
    public var rotation: Rotation
    
    public init(speed: Double, rotation: Rotation) {
        self.speed = speed
        self.rotation = rotation
    }
}
