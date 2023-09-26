//
//  GameScene.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 25/09/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var rollingSpeed: CGFloat = 5
    private var rollingDuration: Double = 0.01
    
    private var buildings: [SKNode] = []
    
    private var obstacle: SKSpriteNode = SKSpriteNode()
    
    private var square = SKSpriteNode()
    
    private var isAtRight = false
    
    private var lastUpdateTime: Double = 0
    // MARK: -
    override func didMove(to view: SKView) {
//        setupObstacle(view)
        setupBuildings(view)
        setupTapGestureRecognizer()
        
        square = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        square.anchorPoint = CGPoint(x: 0, y: 0)
        square.position = CGPoint(x: buildings[0].children[0].frame.width, y: view.frame.height / 3)
        square.zPosition = 1
        
        addChild(square)
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        updateBuildingsBuffer(delta)
    }
    
    // MARK: - Tap
    private func setupTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        
        self.view?.addGestureRecognizer(tapGesture)
    }
        
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .recognized {
            print("move sprite")
            
            if isAtRight {
                square.anchorPoint = CGPoint(x: 0, y: 0)
                square.position = CGPoint(x: buildings[0].children[0].frame.width, y: square.position.y)
            } else {
                square.anchorPoint = CGPoint(x: 1, y: 0)
                square.position = CGPoint(x: (view?.frame.width ?? 0) - buildings[0].children[1].frame.width, y: square.position.y)
            }
            
            self.isAtRight.toggle()
        }
    }
    
    // MARK: - Obstacle
    private func setupObstacle(_ view: SKView) {
        let obstacleHeight = view.frame.height / 6
        obstacle = SKSpriteNode(color: .red, size: CGSize(width: view.frame.width / 3, height: obstacleHeight))
    }
    
    // MARK: - Buildings
    private func updateBuildingsBuffer(_ delta: TimeInterval) {
        guard let view = self.view else { return }
        
        let maxY = buildings[0].position.y + buildings[0].children[0].frame.maxY
        if maxY <= view.frame.minY {
            buildings[0].removeFromParent()
            buildings.remove(at: 0)
        }
        
        if buildings.count < 3 {
            if maxY <= view.frame.maxY + 150 {
                let nextBuildingsYPosition = buildings.last!.position.y + buildings.last!.children[0].frame.maxY - (delta * rollingSpeed / rollingDuration)

                buildings.append(createBuildingParent(view, starterPosition: CGPoint(x: 0, y: nextBuildingsYPosition)))
            }
        }
    }
    
    private func setupBuildings(_ view: SKView) {
        buildings.append(createBuildingParent(view))
        
        let bufferPosition = CGPoint(x: 0, y: buildings[0].position.y + buildings[0].children[0].frame.maxY)
        print(bufferPosition)
        buildings.append(createBuildingParent(view, starterPosition: bufferPosition))
    }
    
    private func createBuildingParent(_ view: SKView, starterPosition: CGPoint = .zero) -> SKNode {
        let parent = SKNode()
        parent.position = starterPosition
        
        createBuildings(view, parent: parent)
        
        self.addChild(parent)
        
        parent.run(.repeatForever(
            .move(by: CGVector(dx: 0, dy: rollingSpeed * -1), duration: rollingDuration)
        ))
        
        return parent
    }
    
    private func createBuildings(_ view: SKView, parent: SKNode) {
        let buildingWidth = view.frame.width / 3
        let buildingHeight = view.frame.height * 2
        
        let building1 = SKSpriteNode(color: .blue, size: CGSize(width: buildingWidth, height: buildingHeight))
        let building2 = SKSpriteNode(color: .blue, size: CGSize(width: buildingWidth, height: buildingHeight))
        
        building1.anchorPoint = CGPoint(x: 0, y: 0)
        building2.anchorPoint = CGPoint(x: 1, y: 0)
        
        building1.position = CGPoint(x: 0, y: 0)
        building2.position = CGPoint(x: view.frame.maxX, y: 0)
        
        parent.addChild(building1)
        parent.addChild(building2)
    }
    
    // MARK: -
}
