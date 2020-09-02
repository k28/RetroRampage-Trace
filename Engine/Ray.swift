//
//  Ray.swift
//  Engine
//
//  Created by K.Hatano on 2020/08/29.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import Foundation

public struct Ray {
    public var origin, direction: Vector
    
    public init(origin: Vector, direction: Vector) {
        self.origin = origin
        self.direction = direction
    }
}

public extension Ray {
    
    var slopeIntercept: (slope: Double, intercept: Double) {
        let slope = direction.y / direction.x
        let intercept = origin.y - slope * origin.x
        return (slope, intercept)
    }
    
}
