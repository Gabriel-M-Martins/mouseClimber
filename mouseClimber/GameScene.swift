//
//  GameScene.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 25/09/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var isGameOver: Bool = false
    
    private var rollingSpeed: CGFloat = 3
    private var rollingDuration: Double = 0.01
    
    private var obstacleFrequency: Int = 10
    
    private var isJumping = false
    
    private var buildings: [SKNode] = []
    
    private var fallingObjects: [(case: FallingObjects, node: SKNode)] = []
    
    private var mouse = SKSpriteNode()
    
    private var isAtRight = false
    
    private var lastUpdateTime: Double = 0
    
    // MARK: -
    override func didMove(to view: SKView) {
        setupBuildings(view)
        setupFallingObjects()
        setupTapGestureRecognizer()
        
        mouse = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        mouse.anchorPoint = CGPoint(x: 0, y: 0)
        mouse.position = CGPoint(x: buildings[0].children[0].frame.width, y: view.frame.height / 3)
        mouse.zPosition = 1
        
        let minYConstraint = SKConstraint.positionY(SKRange(upperLimit: view.frame.height - 50))
        mouse.constraints = [minYConstraint]
        
        addChild(mouse)
        
        mouse.run(.repeatForever(.move(by: CGVector(dx: 0, dy: (rollingSpeed * -1)/2 ), duration: rollingDuration)))
    }
    
    override func update(_ currentTime: TimeInterval) {
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        updateBuildingsBuffer(delta)
        
        if !isGameOver {
            checkGameOver(mouse)
        }
    }
    
    private func checkGameOver(_ sprite: SKSpriteNode) {
        if mouse.position.y < 0 - mouse.size.height {
            self.isGameOver = true
            createGameOverLabels()
            guard let scene = self.scene else { return }
            scene.removeAllActions()
        }
    }
    
    private func createGameOverLabels() {
        guard let view = self.view else { return }
        
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.position = CGPoint(x: view.frame.midX, y: view.frame.midY)
                addChild(gameOverLabel)
                
        let restartButton = SKLabelNode(text: "Restart")
        restartButton.position = CGPoint(x: view.frame.midX, y: self.size.height / 3)
        restartButton.name = "restartButton"
        addChild(restartButton)
    }
    
    private func restartGame() {
        guard let view = self.view else { return }
        let mainScene = GameScene(size: view.frame.size)
        view.presentScene(mainScene)
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
            if !isGameOver {
                if isAtRight {
                    mouse.run(.move(by: CGVector(dx: ((0 - (view?.frame.width ?? 0)) / 3) + mouse.frame.width, dy: 100), duration: 0.1))
                } else {
                    mouse.run(.move(by: CGVector(dx: ((view?.frame.width ?? 0) / 3) - mouse.frame.width, dy: 100), duration: 0.1))
                }
                
                self.isAtRight.toggle()
            }
        }
    }
    
    // MARK: - Falling Objects
    private func setupFallingObjects() {
        self.run(.repeatForever(.sequence([
            .run { [weak self] in
                guard let s = self else { return }
                s.spawnFallingObject(yPosition: s.buildings.last!.children[0].frame.maxY)
            },
            .wait(forDuration: .random(in: 1...(1 + 10/Double(obstacleFrequency))))
        ])))
    }
    
    private func spawnFallingObject(yPosition: CGFloat) {
        guard let view = self.view else { return }
        
        let buildingWidth = buildings[0].children[0].frame.width
        let usableWidth = (start: buildingWidth, end: view.frame.maxX - buildingWidth)
        
        let fallingObject = FallingObjects.allCases.randomElement()!
        let fallingObjectSprite = fallingObject.sprite()
        
        let scale = ( (usableWidth.end - usableWidth.start) / 4) / fallingObjectSprite.size.width
        
        let fallingObjectNode = SKSpriteNode(texture: SKTexture(image: fallingObjectSprite), size: CGSize(width: fallingObjectSprite.size.width * scale, height: fallingObjectSprite.size.height * scale))
        fallingObjectNode.anchorPoint = .zero
        fallingObjectNode.position = CGPoint(x: .random(in: usableWidth.start...usableWidth.end-fallingObjectNode.size.width), y: yPosition)
        
        fallingObjectNode.run(.repeatForever(
            .move(by: CGVector(dx: 0, dy: rollingSpeed * -1 * (fallingObject.fallsFast ? 1.5 : 1) ), duration: rollingDuration)
        ))
        
        fallingObjects.append((fallingObject, fallingObjectNode))
        self.addChild(fallingObjectNode)
    }
    
    // MARK: - Buildings
    private func updateBuildingsBuffer(_ delta: TimeInterval) {
        guard let view = self.view else { return }
        
        let maxY = buildings[0].position.y + buildings[0].children[0].frame.maxY
        if maxY <= view.frame.minY {
            buildings[0].removeFromParent()
            buildings.remove(at: 0)
        }
        
        if buildings.count < 2 {
            if maxY <= view.frame.maxY + 150 {
                let nextBuildingsYPosition = buildings.last!.position.y + buildings.last!.children[0].frame.maxY - (delta * rollingSpeed / rollingDuration)
                
                let newBuildings = spawnBuildingsParent(view, starterPosition: CGPoint(x: 0, y: nextBuildingsYPosition))
                
                buildings.append(newBuildings)
            }
        }
    }
    
    private func setupBuildings(_ view: SKView) {
        buildings.append(spawnBuildingsParent(view))
        
        let bufferPosition = CGPoint(x: 0, y: buildings[0].position.y + buildings[0].children[0].frame.maxY)
        let bufferBuildings = spawnBuildingsParent(view, starterPosition: bufferPosition)
        buildings.append(bufferBuildings)
    }
    
    private func spawnBuildingsParent(_ view: SKView, starterPosition: CGPoint = .zero) -> SKNode {
        let parent = SKNode()
        parent.position = starterPosition
        
        spawnBuildings(view, parent: parent)
        
        self.addChild(parent)
        
        parent.run(.repeatForever(
            .move(by: CGVector(dx: 0, dy: rollingSpeed * -1), duration: rollingDuration)
        ))
        
        return parent
    }
    
    private func spawnBuildings(_ view: SKView, parent: SKNode) {
        let buildingWidth: CGFloat = view.frame.width / 3
        let buildingHeight: CGFloat = ((view.frame.maxY / buildingWidth).rounded()) * buildingWidth * 2
        
        let building1 = SKSpriteNode(color: .clear, size: CGSize(width: buildingWidth, height: buildingHeight))
        let building2 = SKSpriteNode(color: .clear, size: CGSize(width: buildingWidth, height: buildingHeight))

        building1.anchorPoint = CGPoint(x: 0, y: 0)
        building2.anchorPoint = CGPoint(x: 1, y: 0)
        
        building1.position = CGPoint(x: 0, y: 0)
        building2.position = CGPoint(x: view.frame.maxX, y: 0)
          
        building1.zPosition = -10
        building2.zPosition = -10
        
        var obstaclesCreated: Int = 0
        
        // TODO: otimizar isso, aparentemente dá pra renderizar tudo numa só chamada quando a sprite usa a mesma SKTexture (https://developer.apple.com/documentation/spritekit/nodes_for_scene_building/maximizing_node_drawing_performance)
        for i in 0..<Int(buildingHeight/buildingWidth) {
            
            let rndTileSprite1: UIImage
            let rndTileSprite2: UIImage
            
            if obstaclesCreated < obstacleFrequency && Bool.random() {
                if Bool.random() {
                    rndTileSprite1 = ObstacleTiles.allCases.randomElement()!.sprite()
                    rndTileSprite2 = BuildingTiles.allCases.randomElement()!.sprite()
                } else {
                    rndTileSprite2 = BuildingTiles.allCases.randomElement()!.sprite()
                    rndTileSprite1 = ObstacleTiles.allCases.randomElement()!.sprite()
                }
                
                obstaclesCreated += 1
            } else {
                rndTileSprite1 = BuildingTiles.allCases.randomElement()!.sprite()
                rndTileSprite2 = BuildingTiles.allCases.randomElement()!.sprite()
            }
            
            let scale1 = buildingWidth / rndTileSprite1.size.width
            let scale2 = buildingWidth / rndTileSprite2.size.width
            
            let tile1 = SKSpriteNode(texture: SKTexture(image: rndTileSprite1), size: CGSize(width: rndTileSprite1.size.width * scale1, height: rndTileSprite1.size.height * scale1))
            let tile2 = SKSpriteNode(texture: SKTexture(image: rndTileSprite2), size: CGSize(width: rndTileSprite2.size.width * scale2, height: rndTileSprite2.size.height * scale2))
            
            tile1.anchorPoint = CGPoint(x: 0, y: 0)
            tile2.anchorPoint = CGPoint(x: 1, y: 0)
            
            tile1.position = CGPoint(x: 0, y: CGFloat(i) * tile1.frame.height)
            tile2.position = CGPoint(x: 0, y: CGFloat(i) * tile2.frame.height)
            
            building1.addChild(tile1)
            building2.addChild(tile2)
        }
        
        parent.addChild(building1)
        parent.addChild(building2)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if let node = atPoint(location) as? SKLabelNode {
                if node.name == "restartButton" {
                    // Transition back to the main game scene to restart the game
                    restartGame()
                }
            }
        }
    }
    
}
