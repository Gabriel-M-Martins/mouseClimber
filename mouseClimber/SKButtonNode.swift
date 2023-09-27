//
//  SKButtonNode.swift
//  mouseClimber
//
//  Created by Arthur Sobrosa on 27/09/23.
//

import Foundation
import SpriteKit

class SKButtonNode: SKNode {
    
    var image: SKSpriteNode?
    var label: SKLabelNode?
    var action: (() -> Void)?
    
    init(image: SKSpriteNode, label: SKLabelNode, action: (@escaping () -> Void)) {
        self.image = image
        self.label = label
        self.action = action
        super.init()
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.action?()
    }
}
