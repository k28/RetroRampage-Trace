//
//  ViewController.swift
//  RetroRampage
//
//  Created by K.Hatano on 2020/08/20.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import UIKit
import Engine

private let joysticRadius: Double = 40

class ViewController: UIViewController {
    private let imageView = UIImageView()
    private let panGesture = UIPanGestureRecognizer()
    private var world = World(map: loadMap())
    private var lastFrameTime = CACurrentMediaTime()
    private let maximumTimeStep: Double = 1/20
    private let worldTimeStep: Double = 1/120

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpImageView()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update(_:)))
        displayLink.add(to: .main, forMode: .common)
        
        view.addGestureRecognizer(panGesture)
    }

    func setUpImageView() {
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.layer.magnificationFilter = .nearest
    }
    
    @objc func update(_ displayLink: CADisplayLink) {
        let timeStep = min(displayLink.timestamp - lastFrameTime, maximumTimeStep)
        let input = Input(velocity: inputVector)
        let worldSteps = (timeStep / worldTimeStep).rounded(.up)
        for _ in 0 ..< Int(worldSteps) {
            world.update(timeStep: timeStep / worldSteps, input: input)
        }
        lastFrameTime = displayLink.timestamp
        
        let size = Int(min(imageView.bounds.width, imageView.bounds.height))
        var renderer = Renderer(width: size, height: size)
        renderer.draw(world)
        
        imageView.image = UIImage(bitmap: renderer.bitmap)
    }

    private var inputVector: Vector {
        switch panGesture.state {
        case .began, .changed:
            let translation = panGesture.translation(in: view)
            var vector = Vector(x: Double(translation.x), y: Double(translation.y))
            vector /= max(joysticRadius, vector.length)
            
            // joystickの半径を超えて指を動かした時にjoyStickの位置を移動させる
            // (直感的に指を別方向に動かした時に追従できるようにする)
            let position = CGPoint( x: vector.x * joysticRadius,y: vector.y * joysticRadius)
            panGesture.setTranslation(position, in: view)
            return vector
        default:
            return Vector(x: 0, y: 0)
        }
    }
}

private func loadMap() -> Tilemap {
    let jsonURL = Bundle.main.url(forResource: "Map", withExtension: "json")!
    let jsonData = try! Data(contentsOf: jsonURL)
    return try! JSONDecoder().decode(Tilemap.self, from: jsonData)
}

