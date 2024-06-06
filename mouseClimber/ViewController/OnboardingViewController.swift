//
//  OnboardingViewController.swift
//  mouseClimber
//
//  Created by Arthur Sobrosa on 06/06/24.
//

import UIKit

class OnboardingViewController: BackgroundViewController {
    private let viewModel = OnboardingViewModel()
    
    private lazy var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "How to Play"
        lbl.textColor = .systemBackground
        lbl.font = getCustomFont(ofSize: 30)
        
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        return lbl
    }()
    
    private let mouseJumpingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private let mouthImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    private lazy var explanationLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "You can move the mouse by tapping the screen or by moving your mouth"
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textColor = .systemBackground
        lbl.textAlignment = .center
        lbl.font = getCustomFont(ofSize: 20)
        
        lbl.translatesAutoresizingMaskIntoConstraints = false
        
        return lbl
    }()
    
    private lazy var gotItButton: UIButton = {
        let bttn = UIButton()
        bttn.setTitle("Got It!", for: .normal)
        bttn.setTitleColor(.systemBackground, for: .normal)
        bttn.titleLabel?.font = getCustomFont(ofSize: 30)
        bttn.addTarget(self, action: #selector(gotItButtonTapped), for: .touchUpInside)
        
        bttn.translatesAutoresizingMaskIntoConstraints = false
        
        return bttn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        self.setSubviews()
        
        viewModel.onImagesChanged = { [weak self] images in
            guard let self = self else { return }
            
            self.mouseJumpingImageView.image = images[0]
            self.mouthImageView.image = images[1]
        }
    }
    
    private func getCustomFont(ofSize: CGFloat) -> UIFont? {
        guard let customFont = UIFont(name: "IrishGrover-Regular", size: ofSize) else { return nil }
        
        return customFont
    }
    
    @objc private func gotItButtonTapped() {
        UserDefaults.hasOnboarded = true
        navigationController?.popViewController(animated: false)
    }
}

// MARK: - Setting subviews
private extension OnboardingViewController {
    func setSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(mouseJumpingImageView)
        view.addSubview(mouthImageView)
        view.addSubview(explanationLabel)
        view.addSubview(gotItButton)
        
        let padding = UIScreen.main.bounds.height * 0.02
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -padding),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            mouseJumpingImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: padding * 2),
            mouseJumpingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mouseJumpingImageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            mouseJumpingImageView.heightAnchor.constraint(equalTo: mouseJumpingImageView.widthAnchor, multiplier: 0.8),
            
            mouthImageView.topAnchor.constraint(equalTo: mouseJumpingImageView.bottomAnchor, constant: padding / 2),
            mouthImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mouthImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25),
            mouthImageView.widthAnchor.constraint(equalTo: mouthImageView.heightAnchor, multiplier: 0.65),
            
            explanationLabel.topAnchor.constraint(equalTo: mouthImageView.bottomAnchor, constant: padding),
            explanationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            explanationLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding),
            
            gotItButton.topAnchor.constraint(equalTo: explanationLabel.bottomAnchor, constant: padding),
            gotItButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            gotItButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.6),
        ])
    }
}
