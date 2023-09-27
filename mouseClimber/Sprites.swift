//
//  Sprites.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 27/09/23.
//

import Foundation
import UIKit

// TODO: storedSprites guardar uma lista de UIImage inves de só uma p poder criar animação e tal.
enum BuildingTiles: CaseIterable, Hashable {
    case Building1
    case Building2
    
    private static var storedSprites: [Self : UIImage] = [:]
    
    func sprite() -> UIImage {
        switch self {
        case .Building1:
            let img: UIImage
            
            if let foo = Self.storedSprites[self] {
                img = foo
            } else {
                img = UIImage(named: "building0") ?? UIImage()
                _ = Self.storedSprites.updateValue(img, forKey: self)
            }
            return img
            
        case .Building2:
            let img: UIImage
            
            if let foo = Self.storedSprites[self] {
                img = foo
            } else {
                img = UIImage(named: "building0") ?? UIImage()
                _ = Self.storedSprites.updateValue(img, forKey: self)
            }
            return img
        }
    }
}

enum ObstacleTiles: CaseIterable {
    case Cat
    
    private static var storedSprites: [Self : UIImage] = [:]
    
    func sprite() -> UIImage {
        switch self {
        case .Cat:
            let img: UIImage
            
            if let foo = Self.storedSprites[self] {
                img = foo
            } else {
                img = UIImage(named: "cat0") ?? UIImage()
                _ = Self.storedSprites.updateValue(img, forKey: self)
            }
            return img
        }
    }
}
