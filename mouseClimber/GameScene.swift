//
//  GameScene.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 25/09/23.
//

import SpriteKit
import GameplayKit
import ARKit
import AVFoundation

enum Side {
    case right, left
}

class GameScene: SKScene, ARSessionDelegate, SKPhysicsContactDelegate {
    var gameDelegate: GameDelegate?
    
    let arSession = ARSession()
    let faceTrackingConfiguration = ARFaceTrackingConfiguration()
    
    private var currentSide: Side = .left
    
    private var isGameOver: Bool = false
    
    private var rollingSpeed: CGFloat = 3
    private var rollingDuration: Double = 0.01
    
    private var obstacleFrequency: Int = 10
    
    var audioPlayer: AVAudioPlayer?
    var audioGameOver: AVAudioPlayer?
    var audioJump1: AVAudioPlayer?
    var audioJump2: AVAudioPlayer?
    var audioEatCheese: AVAudioPlayer?
    
    private var buildings: [SKNode] = []
    
    private var fallingObjects: [(case: FallingObjects, node: SKNode)] = []
    
    private var mouse = SKSpriteNode()
    private var mouseBody = SKPhysicsBody()
    
    private var background = SKSpriteNode()
    
    private var lastUpdateTime: Double = 0
    
    // MARK: -
    override func didMove(to view: SKView) {
        arSession.run(faceTrackingConfiguration)
        arSession.delegate = self
        
        physicsWorld.contactDelegate = self
        
        setupBuildings(view)
        setupFallingObjects()
        
        setupTapGestureRecognizer()
        
        mouse = SKSpriteNode(color: .clear, size: CGSize(width: view.frame.width / 9, height: view.frame.width * 0.23))
        mouse.anchorPoint = CGPoint(x: 0.5, y: 0)
        mouse.position = CGPoint(x: buildings[0].children[0].frame.width + 20, y: view.frame.height / 3)
        mouse.zPosition = 1
        mouse.name = "mouse"
        mouse.texture = SKTexture(imageNamed: "mouse1")
        
        getWalkingMouseBody(size: mouse.size)
        
        background = SKSpriteNode(imageNamed: "background")
        background.anchorPoint = CGPoint(x: 0, y: 0)
        background.position = CGPoint(x: 0, y: 0)
        background.zPosition = -15
        addChild(background)
        
        let minYConstraint = SKConstraint.positionY(SKRange(upperLimit: view.frame.height - 50))
        mouse.constraints = [minYConstraint]
        
        addChild(mouse)
        
        mouse.run(.repeatForever(.move(by: CGVector(dx: 0, dy: (rollingSpeed * -1)/2 ), duration: rollingDuration)))
        
        self.walk()
        
        setSounds()
    }
    
    override func update(_ currentTime: TimeInterval) {
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        updateBuildingsBuffer(delta)
        removeFallingObjectNodes()
        
        if !isGameOver {
            audioPlayer?.play()
            checkGameOver(mouse)
        }
    }
    
    // MARK: - Mouse Physics Body Config
    private func getWalkingMouseBody(size: CGSize) {
        mouseBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.6, height: size.height), center: CGPoint(x: 0, y: size.height / 2))
        mouseBody.categoryBitMask = 1
        mouseBody.contactTestBitMask = 2
        mouseBody.collisionBitMask = 16
        mouseBody.affectedByGravity = false
        mouseBody.allowsRotation = false
        mouse.physicsBody = mouseBody
    }
    
    private func getJumpingMouseBody(size: CGSize) {
        mouseBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.7, height: size.height * 0.8), center: CGPoint(x: 0, y: size.height / 2))
        mouseBody.categoryBitMask = 1
        mouseBody.contactTestBitMask = 2
        mouseBody.collisionBitMask = 16
        mouseBody.affectedByGravity = false
        mouseBody.allowsRotation = false
        mouse.physicsBody = mouseBody
    }
    
    // MARK: - Animations
    private func setJumpAnimation() -> [SKTexture] {
        var textures: [SKTexture] = []
        for i in 0...1 {
            let texture = SKTexture(imageNamed: "mouse\(i)")
            textures.append(texture)
        }
        textures.append(SKTexture(imageNamed: "mouse1"))
        return textures
    }
    
    private func setWalkAnimation() -> [SKTexture] {
        var textures: [SKTexture] = []
        for i in 1...2 {
            let texture = SKTexture(imageNamed: "mouse\(i)")
            textures.append(texture)
        }
        return textures
    }
    
    // MARK: - Actions
    private func jump(to side: Side) {
        guard let view = self.view else { return }
        
        let width = view.frame.width / 9
        let height = width * 2.13
        
        if side == .right {
            mouse.run(.move(to: CGPoint(x: view.frame.maxX - buildings[0].children[0].frame.width - 20, y: mouse.position.y + 100), duration: 0.2))
            
            mouse.run(.animate(with: setJumpAnimation(), timePerFrame: 0.2))
            
            mouse.size = CGSize(width: height, height: width)
            
            getJumpingMouseBody(size: mouse.size)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.19) {
                self.mouse.size = CGSize(width: width, height: height)
                self.getWalkingMouseBody(size: self.mouse.size)
                self.walk()
            }
        } else {
            mouse.run(.move(to: CGPoint(x: buildings[0].children[0].frame.width + 20, y: mouse.position.y + 100), duration: 0.2))
            
            mouse.run(.animate(with: setJumpAnimation(), timePerFrame: 0.2))
            
            mouse.size = CGSize(width: height, height: width)
            
            getJumpingMouseBody(size: mouse.size)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.19) {
                self.mouse.size = CGSize(width: width, height: height)
                self.getWalkingMouseBody(size: self.mouse.size)
                self.walk()
            }
        }
    }
    
    private func walk() {
        mouse.run(.repeatForever(.animate(with: setWalkAnimation(), timePerFrame: 0.1)))
    }
    
    // MARK: - Sounds
    private func setSounds() {
        if let soundURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "wav") {
            if let audio = try? AVAudioPlayer(contentsOf: soundURL) {
                audioPlayer = audio
                audioPlayer?.volume = 0.1
            }
        }
        
        if let soundURL2 = Bundle.main.url(forResource: "gameOver", withExtension: "wav") {
            if let audio = try? AVAudioPlayer(contentsOf: soundURL2) {
                audioGameOver = audio
                audioGameOver?.volume = 0.1
            }
        }
        
        if let soundURL3 = Bundle.main.url(forResource: "jump", withExtension: "wav") {
            if let audio = try? AVAudioPlayer(contentsOf: soundURL3) {
                audioJump1 = audio
                
            }
            
            if let audio = try? AVAudioPlayer(contentsOf: soundURL3) {
                audioJump2 = audio
            }
        }
        
        if let soundURL4 = Bundle.main.url(forResource: "eatCheese", withExtension: "wav") {
            if let audio = try? AVAudioPlayer(contentsOf: soundURL4) {
                audioEatCheese = audio
            }
        }
    }
    
    // MARK: - Game Over
    private func checkGameOver(_ sprite: SKSpriteNode) {
        if mouse.position.y < 0 - mouse.size.height {
            performGameOver()
        }
    }
    
    private func performGameOver() {
        self.isGameOver = true
        gameDelegate?.gameOver()
        
        guard let scene = self.scene else { return }
        scene.removeAllActions()
        mouse.removeFromParent()
        audioPlayer?.pause()
        audioGameOver?.play()
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
        if !isGameOver {
            if sender.state == .recognized {
                if self.currentSide == .left {
                    mouse.xScale = -1
                    
                    jump(to: .right)
                    self.currentSide = .right
                    
                    audioJump1?.play()
                } else {
                    mouse.xScale = 1
                    
                    jump(to: .left)
                    self.currentSide = .left
                    
                    audioJump2?.play()
                }
            }
        }
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

            if mouthRight > mouthLeft {
                if mouthRight > 0.5 && self.currentSide == .left {
                    mouse.xScale = -1
                    
                    jump(to: .right)
                    self.currentSide = .right
                    
                    audioJump1?.play()
                }
            } else {
                if mouthLeft > 0.5 && self.currentSide == .right {
                    mouse.xScale = 1
                    
                    jump(to: .left)
                    self.currentSide = .left
                    
                    audioJump2?.play()
                }
            }
        }
    }
    
    // MARK: - Falling Objects
    private func removeFallingObjectNodes() {
        guard let view = self.view else { return }
        
        if fallingObjects.count > 0 {
            if fallingObjects[0].node.frame.minY <= view.frame.minY {
                fallingObjects[0].node.removeFromParent()
                fallingObjects.remove(at: 0)
            }
        }
    }
    
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
        
        let proportion = fallingObject.proportion
        let size = CGSize(width: (usableWidth.end - usableWidth.start) / proportion, height: (usableWidth.end - usableWidth.start) / proportion)
        let fallingObjectSprite = fallingObject.texture(ofSize: size)
        
        let fallingObjectNode = SKSpriteNode(texture: fallingObjectSprite)
        
        fallingObjectNode.anchorPoint = .zero
        fallingObjectNode.position = CGPoint(x: .random(in: usableWidth.start...usableWidth.end-fallingObjectNode.size.width), y: yPosition)
        fallingObjectNode.name = "fallingObject"
        
        fallingObjectNode.run(.repeatForever(
            .move(by: CGVector(dx: 0, dy: rollingSpeed * -1 * (fallingObject.fallsFast ? 1.5 : 1) ), duration: rollingDuration)
        ))
        
        let fallingObjectBody = SKPhysicsBody(rectangleOf: fallingObjectNode.size, center: CGPoint(x: fallingObjectNode.frame.width / 2, y: fallingObjectNode.frame.height / 2))
        fallingObjectBody.affectedByGravity = false
        fallingObjectBody.allowsRotation = false
        
        if fallingObject == .Cheese {
            fallingObjectBody.categoryBitMask = 2
            fallingObjectBody.contactTestBitMask = 1
        } else if fallingObject == .Obstacle {
            fallingObjectBody.categoryBitMask = 4
            fallingObjectBody.contactTestBitMask = 1
        }
        
        fallingObjectBody.collisionBitMask = 8
        fallingObjectNode.physicsBody = fallingObjectBody
        
        fallingObjects.append((fallingObject, fallingObjectNode))
        self.addChild(fallingObjectNode)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Obstacle contact
        if (bodyA.categoryBitMask == 1 && bodyB.categoryBitMask == 4) || (bodyA.categoryBitMask == 4 && bodyB.categoryBitMask == 1) {
            performGameOver()
            return
        }
        
        // Cheese contact
        if (bodyA.categoryBitMask == 1 && bodyB.categoryBitMask == 2) || (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 1) {
            var body = SKPhysicsBody()
            
            if bodyA.categoryBitMask == 2 {
                body = bodyA
            } else {
                body = bodyB
            }
            
            body.node?.removeFromParent()
            
            if let index = fallingObjects.firstIndex(where: { $0.node === body.node }) {
                fallingObjects.remove(at: index)
            }
            
            gameDelegate?.increaseCheeseCount()
            if !isGameOver {
                audioEatCheese?.play()
            }
        }
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
                    rndTileSprite1 = ObstacleTiles.allCases.randomElement()!.texture(ofSize: tileSize)
                    rndTileSprite2 = BuildingTiles.allCases.randomElement()!.texture(ofSize: tileSize)
                } else {
                    rndTileSprite1 = BuildingTiles.allCases.randomElement()!.texture(ofSize: tileSize)
                    rndTileSprite2 = ObstacleTiles.allCases.randomElement()!.texture(ofSize: tileSize)
                }
                
                obstaclesCreated += 1
            } else {
                rndTileSprite1 = BuildingTiles.allCases.randomElement()!.texture(ofSize: tileSize)
                rndTileSprite2 = BuildingTiles.allCases.randomElement()!.texture(ofSize: tileSize)
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
}
