//
//  ViewController.swift
//  RetroRampage
//
//  Created by K.Hatano on 2020/08/20.
//  Copyright © 2020 K.Hatano. All rights reserved.
//

import UIKit
import Engine

class ViewController: UIViewController {
    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpImageView()
        
        var bitmap = Bitmap(width: 8, height: 8, color: .white)
        bitmap[0, 0] = .blue
        
        imageView.image = UIImage(bitmap: bitmap)
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

}

