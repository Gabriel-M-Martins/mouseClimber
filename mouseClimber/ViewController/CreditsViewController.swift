//
//  CreditsViewController.swift
//  mouseClimber
//
//  Created by Fabrício Masiero on 29/09/23.
//

import UIKit

class CreditsViewController: BackgroundViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let customFontSize: CGFloat = 36
        
        guard let customFont = UIFont(name: "IrishGrover-Regular", size: customFontSize) else {
            fatalError("Failed to load custom font")
        }
        
        let creditTexts = [
            "CREDITS",
            "Victoria Trindade",
            "Arthur Sobrosa",
            "Fabrício Masiero",
            "Gabriel Martins",
            "Luciana Santini"
        ]
        
        var previousLabel: UILabel?
        
        for (index, text) in creditTexts.enumerated() {
            let label = UILabel()
            label.text = text
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = customFont
            
            label.textColor = (index == 0) ? UIColor(red: 245.0/255.0, green: 190.0/255.0, blue: 65.0/255.0, alpha: 1.0) : .systemBackground
            
            view.addSubview(label)
            
            if let previousLabel = previousLabel {
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: previousLabel.bottomAnchor, constant: 30),
                    label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
            } else {
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height * 0.2),
                    label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
                ])
            }
            
            previousLabel = label
        }
    }
}
