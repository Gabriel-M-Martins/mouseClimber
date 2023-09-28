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
//typealias StorableTexture = RawRepresentable & CaseIterable & Storable

// MARK: - Sprites
enum BuildingTiles: String, CaseIterable, Storable {
    case Building1 = "building0"
    case Building2 = "building1"
    
    internal static var store: [BuildingTiles : SKTexture] = [:]
}

enum ObstacleTiles: String, CaseIterable, Storable {
    case Cat = "cat"
    
    internal static var store: [Self : SKTexture] = [:]
    
}

enum FallingObjects: String, CaseIterable, Storable {
    case Cheese = "cheese"
    case Obstacle = "obstacle"
    
    internal static var store: [Self : SKTexture] = [:]
    
    var fallsFast: Bool {
        switch self {
        case .Cheese:
            return false
        case .Obstacle:
            return true
        }
    }
    
    var proportion: CGFloat {
        switch self {
            case .Cheese:
                return 2
            case .Obstacle:
                return 3
        }
    }
}

// MARK: - Storable
protocol Storable where Self: RawRepresentable & Hashable, Self.RawValue == String {
    associatedtype StoredType
    
    static var store: [Self : StoredType] { get set }
}

extension Storable where StoredType == SKTexture {
    func texture(ofSize size: CGSize) -> SKTexture {
        var texture: SKTexture
        
        if let storedTexture = Self.store[self] {
            texture = storedTexture
        } else {
            let img = (UIImage(named: self.rawValue) ?? UIImage()).scalePreservingAspectRatio(targetSize: size)
            texture = SKTexture(image: img)
            _ = Self.store.updateValue(texture, forKey: self)
        }
        
        return texture
    }
}

// MARK: - UIImage Extension
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
