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
    public var isFiring: Bool
    
    public init(speed: Double, rotation: Rotation, isFiring: Bool) {
        self.speed = speed
        self.rotation = rotation
        self.isFiring = isFiring
    }
}
