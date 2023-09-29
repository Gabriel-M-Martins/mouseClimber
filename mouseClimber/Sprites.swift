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
//

struct OrderedOverlayedImageConfigurations {
    let configurations: [OverlayedImagesConfiguration]
    
    init(configurations: [OverlayedImagesConfiguration]) {
        self.configurations = configurations.sorted(by: { $0.layoutOrder < $1.layoutOrder })
    }
}

struct OverlayedImagesConfiguration {
    let images: [UIImage]
    let hittable: Bool
    let isAnimatable: Bool
    let layoutOrder: Int
    let scalesUsingWidth: Bool
    let preferredAnchor: Anchor
    let imageSize: CGSize
    
    enum Anchor {
        case Middle
        case Extremities
    }
    
    init(images: [UIImage], layoutOrder: Int, hittable: Bool = false, scalesUsingWidth: Bool = true, preferredAnchor: Anchor = .Extremities) {
        self.images = images
        self.isAnimatable = self.images.count > 1
        self.layoutOrder = layoutOrder
        self.hittable = hittable
        self.scalesUsingWidth = scalesUsingWidth
        self.preferredAnchor = preferredAnchor
        self.imageSize = self.images[0].size
    }
}

// MARK: - Sprites
enum BuildingTiles: String, CaseIterable, Storable {
    case Building1 = "building0"
    case Building2 = "building1"
    
    internal static var store: [BuildingTiles : SKTexture] = [:]
    
    // fazer retornar uma "configuração" de como cada imagem tem que aparecer
    var overlayedImages: OrderedOverlayedImageConfigurations? {
        switch self {
        case .Building1:
            return nil
        case .Building2:
            return .init(configurations: [
                .init(images: [.beirada], layoutOrder: 0),
                .init(images: [.gato0, .gato1], layoutOrder: 1, hittable: true, scalesUsingWidth: false, preferredAnchor: .Middle)
            ])
        }
    }
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
            return 5
        case .Obstacle:
            return 6
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

/**
 Composite two or more image on top of one another to create a single image.
 This function assumes all images are same size.

 - Parameters:
 - images: An array of UIImages

 - returns: A compsite image composed of the array of images passed in
 */
func compositeImages(images: [UIImage]) -> UIImage {
    var compositeImage: UIImage!
    if images.count > 0 {
        // Get the size of the first image.  This function assume all images are same size
        let size: CGSize = CGSize(width: images[0].size.width, height: images[0].size.height)
        UIGraphicsBeginImageContext(size)
        for image in images {
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            image.draw(in: rect)
        }
        compositeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    return compositeImage
}
