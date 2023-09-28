//
//  GameViewController.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 25/09/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameDelegate {
    @IBOutlet weak var gameOverView: UIStackView!
    
    @IBOutlet weak var cheesesEaten: UILabel!
    @IBOutlet weak var cheeseRecordLabel: UILabel!
    
    private var cheeseCount: Int = 0
    
    override func viewDidLoad() {
        self.navigationController?.navigationBar.isHidden = true

        gameOverView.isHidden = true
        
        super.viewDidLoad()

        presentGame()
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
        self.navigationController?.popViewController(animated: true)
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
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
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
