//
//  GameScene.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 25/09/23.
//

import SpriteKit
import GameplayKit
import ARKit

enum Side {
    case right, left
}

class GameScene: SKScene, ARSessionDelegate {
    let arSession = ARSession()
    let faceTrackingConfiguration = ARFaceTrackingConfiguration()
    
    private var currentSide: Side = .left
    
    private var isGameOver: Bool = false
    
    private var rollingSpeed: CGFloat = 3
    private var rollingDuration: Double = 0.01
    
    private var obstacleFrequency: Int = 10
    
    private var isJumping = false
    
    private var buildings: [SKNode] = []
    
    private var fallingObjects: [(case: FallingObjects, node: SKNode)] = []
    
    private var mouse = SKSpriteNode()
    
    private var lastUpdateTime: Double = 0
    
    // MARK: -
    override func didMove(to view: SKView) {
        arSession.run(faceTrackingConfiguration)
        arSession.delegate = self
        
        setupBuildings(view)
        setupFallingObjects()
        
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
//        updateFallingObjects()
        
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
    
    // MARK: - Mouth Movement
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        if let currentFrame = arSession.currentFrame,
           let faceAnchor = currentFrame.anchors.first(where: { $0 is ARFaceAnchor }) as? ARFaceAnchor {
            
            // Access face tracking data from the ARFaceAnchor object.
            let blendShapes = faceAnchor.blendShapes
            
            // Use this data to update your SpriteKit scene.
            updateSpriteKitScene(withBlendShapes: blendShapes)
        }
    }
    
    func updateSpriteKitScene(withBlendShapes blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        if !isGameOver {
            guard let mouthRight = blendShapes[.mouthLeft] as? CGFloat, let mouthLeft = blendShapes[.mouthRight] as? CGFloat else { return }

            guard let view = self.view else { return }
            
            if mouthLeft > mouthRight {
                if mouthLeft > 0.5 && self.currentSide == .right {
                    self.currentSide = .left
                    mouse.run(.move(to: CGPoint(x: buildings[0].children[0].frame.width, y: mouse.position.y + 100), duration: 0.1))
                }
            } else {
                if mouthRight > 0.5 && self.currentSide == .left {
                    self.currentSide = .right
                    mouse.run(.move(to: CGPoint(x: view.frame.width - buildings[0].children[0].frame.width - mouse.frame.width, y: mouse.position.y + 100), duration: 0.1))
                }
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
        
        let size = CGSize(width: (usableWidth.end - usableWidth.start) / 4, height: (usableWidth.end - usableWidth.start) / 4)
        let fallingObjectSprite = fallingObject.sprite(ofSize: size)
        
        let fallingObjectNode = SKSpriteNode(texture: fallingObjectSprite)
        
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
        
        let tileSize = CGSize(width: buildingWidth, height: buildingWidth)
        
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
            let rndTileSprite1: SKTexture
            let rndTileSprite2: SKTexture
            
            if obstaclesCreated < obstacleFrequency && Bool.random() {
                if Bool.random() {
                    rndTileSprite1 = ObstacleTiles.allCases.randomElement()!.sprite(ofSize: tileSize)
                    rndTileSprite2 = BuildingTiles.allCases.randomElement()!.sprite(ofSize: tileSize)
                } else {
                    rndTileSprite1 = BuildingTiles.allCases.randomElement()!.sprite(ofSize: tileSize)
                    rndTileSprite2 = ObstacleTiles.allCases.randomElement()!.sprite(ofSize: tileSize)
                }
                
                obstaclesCreated += 1
            } else {
                rndTileSprite1 = BuildingTiles.allCases.randomElement()!.sprite(ofSize: tileSize)
                rndTileSprite2 = BuildingTiles.allCases.randomElement()!.sprite(ofSize: tileSize)
            }
            
            let tile1 = SKSpriteNode(texture: rndTileSprite1)
            let tile2 = SKSpriteNode(texture: rndTileSprite2)
            
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
