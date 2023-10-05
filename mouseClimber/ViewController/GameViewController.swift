//
//  GameViewController.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 25/09/23.
//

import UIKit
import SpriteKit
import GameplayKit

@available(iOS 15, *)
class GameViewController: UIViewController, GameDelegate {
    @IBOutlet weak var gameOverView: UIStackView!
    
    @IBOutlet weak var cheesesEaten: UILabel!
    @IBOutlet weak var cheeseRecordLabel: UILabel!
    
    @IBOutlet weak var gameOverLabel: UILabel!
    @IBOutlet weak var finalCheesesEaten: UILabel!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var restartButton: UIButton!
    
    private var cheeseCount: Int = 0
    
    private var metersCount: Int = 0
    
    private var currentScene: GameScene?
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = true

        gameOverView.isHidden = true
        
        super.viewDidLoad()

        presentGame()
        
        gameOverLabel.font = UIFont(name: "IrishGrover-Regular", size: 30)
        gameOverLabel.textColor = .systemBackground
        
        finalCheesesEaten.font = UIFont(name: "IrishGrover-Regular", size: 20)
        finalCheesesEaten.textColor = .systemBackground
        
        menuButton.titleLabel?.font = UIFont(name: "IrishGrover-Regular", size: 24)
        menuButton.tintColor = .systemBackground
        
        restartButton.titleLabel?.font = UIFont(name: "IrishGrover-Regular", size: 24)
        restartButton.tintColor = .systemBackground
        
        cheesesEaten.font = UIFont(name: "IrishGrover-Regular", size: 20)
        cheesesEaten.textColor = .systemBackground
        
        cheeseRecordLabel.font = UIFont(name: "IrishGrover-Regular", size: 20)
        cheeseRecordLabel.textColor = .systemBackground
    }

	override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
		if UIDevice.current.userInterfaceIdiom == .phone {
			return .allButUpsideDown
		} else {
			return .all
		}
	}

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func backToMainMenu(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
        currentScene?.audioGameOver?.stop()
    }
    
    @IBAction func restartGame(_ sender: Any) {
        cheeseCount = 0
        cheesesEaten.text = String(cheeseCount)
        presentGame()
    }
    
    private func presentGame() {
        gameOverView.isHidden = true
        
        if let view = self.view as! SKView? {
            let scene = GameScene(size: view.frame.size)
            scene.anchorPoint = CGPoint(x: 0, y: 0)
            scene.scaleMode = .aspectFill
            scene.gameDelegate = self
            currentScene = scene
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
            view.showsPhysics = false
        }
    }
    
    func gameOver() {
        gameOverView.isHidden = false
        cheeseRecordLabel.text = String(cheeseCount)
        GameKitHelper.shared.submitScore(points: cheeseCount)
    }
    
    func increaseCheeseCount() {
        cheeseCount += 1
        cheesesEaten.text = String(cheeseCount)
    }
}

protocol GameDelegate {
    func gameOver()
    func increaseCheeseCount()
}
