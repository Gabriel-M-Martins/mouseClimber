//
//  GameViewController.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 25/09/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        if let view = self.view as! SKView? {
            let scene = GameScene(size: view.frame.size)
            scene.anchorPoint = CGPoint(x: 0, y: 0)
            scene.scaleMode = .aspectFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
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
}


////
////  GameViewController.swift
////  mouseClimber
////
////  Created by Gabriel Medeiros Martins on 25/09/23.
////
//
//import UIKit
//import SpriteKit
//import GameplayKit
//import GameKit
//
//class GameViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        if let view = self.view as? SKView {
//			authenticateLocalPlayer()
//			
//            let scene = MenuScene(size: view.frame.size)
//            scene.anchorPoint = CGPoint(x: 0.5, y: 0)
////            scene.scaleMode = .aspectFill
//            view.presentScene(scene)
//            view.ignoresSiblingOrder = true
//            
//            view.showsFPS = true
//            view.showsNodeCount = true
//			
//        }
//    }
//	
//	func authenticateLocalPlayer() {
//		let localPlayer = GKLocalPlayer.local
//		
//		localPlayer.authenticateHandler = {(viewController, error) -> Void in
//			if (viewController != nil) {
//				self.present(viewController!, animated: true, completion: nil)
//			}
//			else {
//				print((GKLocalPlayer.local.isAuthenticated))
//			}
//		}
//	}
//
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        if UIDevice.current.userInterfaceIdiom == .phone {
//            return .allButUpsideDown
//        } else {
//            return .all
//        }
//    }
//
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
//}
