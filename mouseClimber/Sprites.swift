//
//  Sprites.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 27/09/23.
//

import Foundation
import UIKit
import SpriteKit

// TODO: storedSprites guardar uma lista de UIImage inves de só uma p poder criar animação e tal.
enum BuildingTiles: CaseIterable {
    case Building1
    case Building2
    
    private static var storedSprites: [Self : SKTexture] = [:]
    
    func sprite(ofSize size: CGSize) -> SKTexture {
        switch self {
        case .Building1:
            var texture: SKTexture
            
            if let storedTexture = Self.storedSprites[self] {
                texture = storedTexture
            } else {
                let img = (UIImage(named: "building0") ?? UIImage()).scalePreservingAspectRatio(targetSize: size)
                texture = SKTexture(image: img)
                _ = Self.storedSprites.updateValue(texture, forKey: self)
            }
            return texture
            
        case .Building2:
            var texture: SKTexture
            
            if let storedTexture = Self.storedSprites[self] {
                texture = storedTexture
            } else {
                let img = (UIImage(named: "building0") ?? UIImage()).scalePreservingAspectRatio(targetSize: size)
                texture = SKTexture(image: img)
                _ = Self.storedSprites.updateValue(texture, forKey: self)
            }
            return texture
        }
    }
}

enum ObstacleTiles: CaseIterable {
    case Cat
    
    private static var storedSprites: [Self : SKTexture] = [:]
    
    func sprite(ofSize size: CGSize) -> SKTexture {
        switch self {
        case .Cat:
            var texture: SKTexture
            
            if let storedTexture = Self.storedSprites[self] {
                texture = storedTexture
            } else {
                let img = (UIImage(named: "building0") ?? UIImage()).scalePreservingAspectRatio(targetSize: size)
                texture = SKTexture(image: img)
                _ = Self.storedSprites.updateValue(texture, forKey: self)
            }
            return texture
        }
    }
}

enum FallingObjects: CaseIterable {
    case Cheese
    case Obstacle
    
    private static var storedSprites: [Self : SKTexture] = [:]
    
    var fallsFast: Bool {
        switch self {
        case .Cheese:
            return false
        case .Obstacle:
            return true
        }
    }
    
    func sprite(ofSize size: CGSize) -> SKTexture {
        switch self {
        case .Cheese:
            var texture: SKTexture
            
            if let storedTexture = Self.storedSprites[self] {
                texture = storedTexture
            } else {
                let img = (UIImage(named: "building0") ?? UIImage()).scalePreservingAspectRatio(targetSize: size)
                texture = SKTexture(image: img)
                _ = Self.storedSprites.updateValue(texture, forKey: self)
            }
            return texture
            
        case .Obstacle:
            var texture: SKTexture
            
            if let storedTexture = Self.storedSprites[self] {
                texture = storedTexture
            } else {
                let img = (UIImage(named: "building0") ?? UIImage()).scalePreservingAspectRatio(targetSize: size)
                texture = SKTexture(image: img)
                _ = Self.storedSprites.updateValue(texture, forKey: self)
            }
            return texture
        }
    }
}

extension UIImage {
    func scalePreservingAspectRatio(targetSize: CGSize) -> UIImage {
        // Determine the scale factor that preserves aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        let scaleFactor = min(widthRatio, heightRatio)
        
        // Compute the new image size that preserves aspect ratio
        let scaledImageSize = CGSize(
            width: size.width * scaleFactor,
            height: size.height * scaleFactor
        )

        // Draw and return the resized UIImage
        let renderer = UIGraphicsImageRenderer(
            size: scaledImageSize
        )

        let scaledImage = renderer.image { _ in
            self.draw(in: CGRect(
                origin: .zero,
                size: scaledImageSize
            ))
        }
        
        return scaledImage
    }
}
