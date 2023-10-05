//
//  BackgroundViewController.swift
//  mouseClimber
//
//  Created by Fabrício Masiero on 29/09/23.
//

import UIKit

class BackgroundViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let backgroundImage = UIImageView(image: UIImage(named: "background"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = self.view.bounds
        
        self.view.addSubview(backgroundImage)
        self.view.sendSubviewToBack(backgroundImage)
    }
}
