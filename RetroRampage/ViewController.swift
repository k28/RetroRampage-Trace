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
    private let tapGesture = UITapGestureRecognizer()
    private var world = World(map: loadMap())
    private var lastFrameTime = CACurrentMediaTime()
    private let maximumTimeStep: Double = 1/20
    private let worldTimeStep: Double = 1/120
    private let textures = loadTextures()
    private var lastFiredTime = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }
        
        setUpImageView()
        
        let displayLink = CADisplayLink(target: self, selector: #selector(update(_:)))
        displayLink.add(to: .main, forMode: .common)
        
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(tapGesture)

        tapGesture.addTarget(self, action: #selector(fire(_:)))
        tapGesture.delegate = self
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
        
        let inputVector = self.inputVector
        let rotation = inputVector.x * world.player.turningSpeed * worldTimeStep
        let input = Input(speed: -inputVector.y,
                          rotation: Rotation(sine: sin(rotation), cosine: cos(rotation)),
                          isFiring: lastFiredTime > lastFrameTime
        )
        let worldSteps = (timeStep / worldTimeStep).rounded(.up)
        for _ in 0 ..< Int(worldSteps) {
            world.update(timeStep: timeStep / worldSteps, input: input)
        }
        lastFrameTime = displayLink.timestamp
        
        let width = Int(imageView.bounds.width), height = Int(imageView.bounds.height)
        var renderer = Renderer(width: width, height: height, textures: textures)
        renderer.draw(world)
        // renderer.draw2D(world)

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
    
    @objc func fire(_ gestureRecognizer: UITapGestureRecognizer) {
        lastFiredTime = CACurrentMediaTime()
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

public func loadMap() -> Tilemap {
    let jsonURL = Bundle.main.url(forResource: "Map", withExtension: "json")!
    let jsonData = try! Data(contentsOf: jsonURL)
    return try! JSONDecoder().decode(Tilemap.self, from: jsonData)
}

public func loadTextures() -> Textures {
    return Textures(loader: { name in
        Bitmap(image: UIImage(named: name)!)!
    })
}

