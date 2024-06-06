//
//  OnboardingViewModel.swift
//  mouseClimber
//
//  Created by Arthur Sobrosa on 06/06/24.
//

import UIKit
import Combine

class OnboardingViewModel {
    public var onImagesChanged: (([UIImage?]) -> Void)?
    @Published private var count = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.startAnimations()
    }
    
    private func startAnimations() {
        Timer.publish(every: 0.2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.count += 1
            }
            .store(in: &cancellables)
        
        $count
            .sink { [weak self] count in
                guard let self = self else { return }
                
                let mouseImageName = "mouseJumping" + "\(count % 4)"
                let currentMouseImage = UIImage(named: mouseImageName)
                
                let mouthImageName = "mouth" + "\(count % 4)"
                let currentMouthImage = UIImage(named: mouthImageName)
                
                self.onImagesChanged?([currentMouseImage, currentMouthImage])
            }
            .store(in: &cancellables)
    }
    
    public func stopAnimations() {
        self.cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }
}
