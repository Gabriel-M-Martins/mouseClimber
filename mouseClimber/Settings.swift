//
//  Settings.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 28/09/23.
//

import Foundation
import SpriteKit

struct Settings {
    static var buildingTileSize: CGFloat = 100
    
    static var hasFinishedLoadingTiles: Bool = false
    static var validatedGameCenter: Bool = false
    
    init(view: UIView) {
        Self.buildingTileSize = view.frame.width / 5
    }
}
