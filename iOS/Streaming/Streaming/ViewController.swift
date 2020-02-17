//
//  ViewController.swift
//  Streaming
//
//  Created by Siyuan Yao on 2/17/20.
//  Copyright © 2020 Siyuan Yao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var imageView: UIImageView?
    let streamer = Streamer()
    @IBOutlet weak var iV: UIImageView!
    @IBOutlet weak var MainTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        streamer.delegate = self
        streamer.initialize()
        streamer.send()
    }

    
    
}

extension ViewController: StreamerDelegate {
    func received(img:UIImage) {
        updateImage(img: img)
        MainTitle.text = "OK"
    }
    
    private func updateImage(img:UIImage) {
        iV.image = img
    }
}
