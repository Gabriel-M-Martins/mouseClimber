//
//  GameScene.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 25/09/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var buildings: SKNode = SKNode()
    private var building1: SKSpriteNode = SKSpriteNode()
    private var building2: SKSpriteNode = SKSpriteNode()
    
    private var obstacle: SKSpriteNode = SKSpriteNode()
    
    override func didMove(to view: SKView) {
        setupObstacle(view)
        setupBuildings(view)
        
        self.addChild(buildings)
//        buildings.run(.repeatForever(
//            .move(by: CGVector(dx: 0, dy: -0.5), duration: 0.01)
//        ))
        
//        print(view.frame.maxY)
//        print(buildings.children[0].frame.maxY)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        guard let view = self.view else { return }
        
//        if buildings.children[0].frame.maxY == view.frame.maxY {
//           print("coe")
//        }
    }
    
    private func setupObstacle(_ view: SKView) {
        let obstacleHeight = view.frame.height / 6
        obstacle = SKSpriteNode(color: .red, size: CGSize(width: view.frame.width / 3, height: obstacleHeight))
    }
    
    private func setupBuildings(_ view: SKView) {
        let buildingWidth = view.frame.width / 3
        let buildingHeight = view.frame.height * 2
        
        let buildingXPosition = (view.frame.width / 1.5)
        
        building1 = SKSpriteNode(color: .blue, size: CGSize(width: buildingWidth, height: buildingHeight))
        building2 = SKSpriteNode(color: .blue, size: CGSize(width: buildingWidth, height: buildingHeight))
        
        building1.anchorPoint = CGPoint(x: 0.5, y: 0)
        building2.anchorPoint = CGPoint(x: 0.5, y: 0)
        
        print(view.frame.height)
        print(view.frame)
        building1.position = CGPoint(x: 0 - buildingXPosition, y: -426)
        building2.position = CGPoint(x: buildingXPosition, y: 0)
        
        buildings.addChild(building1)
        buildings.addChild(building2)
    }
}
