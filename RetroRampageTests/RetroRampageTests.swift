//
//  RetroRampageTests.swift
//  RetroRampageTests
//
//  Created by K.Hatano on 2020/10/11.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import XCTest
import Engine
import RetroRampage

class RetroRampageTests: XCTestCase {
    
    let world = World(map: loadMap())
    let textures = loadTextures()
    
    func testRenderFrame() {
        // The measure {} block wrapped around the drawing code is a built-in method of XCTestCase that automatically executes and benchmarks the code inside it.
        self.measure {
            var renderer = Renderer(width: 1000, height: 1000, textures: textures)
            renderer.draw(world)
        }
    }
}
