//
//  GameScene.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 25/09/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    private var rollingSpeed: CGFloat = 3
    private var rollingDuration: Double = 0.01
    
    private var obstacleFrequency: Int = 10
    
    private var buildings: [SKNode] = []
    
    private var obstacles: [SKNode] = []
    private var obstacle: SKSpriteNode = SKSpriteNode()
    
    private var square = SKSpriteNode()
    
    private var isAtRight = false
    
    private var lastUpdateTime: Double = 0
    
    // MARK: -
    override func didMove(to view: SKView) {
        setupBuildings(view)
        
        setupTapGestureRecognizer()
        
        square = SKSpriteNode(color: .red, size: CGSize(width: 40, height: 40))
        square.anchorPoint = CGPoint(x: 0, y: 0)
        square.position = CGPoint(x: buildings[0].children[0].frame.width, y: view.frame.height / 3)
        square.zPosition = 1
        
        addChild(square)
    }
    
    override func update(_ currentTime: TimeInterval) {
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
            if isAtRight {
                square.run(.move(by: CGVector(dx: ((0 - (view?.frame.width ?? 0)) / 3) + square.frame.width, dy: 0), duration: 0.2))
            } else {
                square.run(.move(by: CGVector(dx: ((view?.frame.width ?? 0) / 3) - square.frame.width, dy: 0), duration: 0.2))
            }
            
            self.isAtRight.toggle()
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
        
        if buildings.count < 3 {
            if maxY <= view.frame.maxY + 150 {
                let nextBuildingsYPosition = buildings.last!.position.y + buildings.last!.children[0].frame.maxY - (delta * rollingSpeed / rollingDuration)
                
                let foo = buildings.last!.position
                print(foo)
                
                let newBuildings = createBuildingParent(view, starterPosition: CGPoint(x: 0, y: nextBuildingsYPosition))
                
                buildings.append(newBuildings)
            }
        }
    }
    
    private func setupBuildings(_ view: SKView) {
        buildings.append(createBuildingParent(view))
        
        let bufferPosition = CGPoint(x: 0, y: buildings[0].position.y + buildings[0].children[0].frame.maxY)
        let bufferBuildings = createBuildingParent(view, starterPosition: bufferPosition)
        
        buildings.append(bufferBuildings)
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
        let buildingWidth: CGFloat = view.frame.width / 3
        let buildingHeight: CGFloat = ((view.frame.maxY / buildingWidth).rounded()) * buildingWidth * 2
        
        let building1 = SKSpriteNode(color: .blue, size: CGSize(width: buildingWidth, height: buildingHeight))
        let building2 = SKSpriteNode(color: .blue, size: CGSize(width: buildingWidth, height: buildingHeight))

        building1.anchorPoint = CGPoint(x: 0, y: 0)
        building2.anchorPoint = CGPoint(x: 1, y: 0)
        
        building1.position = CGPoint(x: 0, y: 0)
        building2.position = CGPoint(x: view.frame.maxX, y: 0)
          
        building1.zPosition = -10
        building2.zPosition = -10

        let scale = buildingWidth / Settings.Building.size.width
        for i in 0..<Int(buildingHeight/buildingWidth) {
            let rndTileSprite1 = BuildingTiles.allCases.randomElement()!.sprite()
            let rndTileSprite2 = BuildingTiles.allCases.randomElement()!.sprite()
            
            let tile1 = SKSpriteNode(texture: SKTexture(image: rndTileSprite1), size: CGSize(width: rndTileSprite1.size.width * scale, height: rndTileSprite1.size.height * scale))
            let tile2 = SKSpriteNode(texture: SKTexture(image: rndTileSprite2), size: CGSize(width: rndTileSprite2.size.width * scale, height: rndTileSprite2.size.height * scale))
            
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
    
    // MARK: -
}

enum Obstacle: CaseIterable {
    case cat
    case cheese
}

enum BuildingTiles: CaseIterable {
    case building
//    case cat
    
    func sprite() -> UIImage {
        switch self {
        case .building:
            return Settings.Building.sprites.randomElement() ?? UIImage()
//        case .cat:
//            return Settings.Cat.sprites.randomElement() ?? UIImage()
        }
    }
}

struct Settings {
    struct Building {
        static var size: CGSize = {
            return Self.sprites.first?.size ?? .zero
        }()
        
        
        static var sprites: [UIImage] = {
            var result = [UIImage]()
            for i in 0..<3 {
                if let img = UIImage(named: "building\(i)") {
                    result.append(img)
                }
            }
            return result
        }()
    }
    
    struct Cat {
        static var sprites = [UIImage]()
    }
}
