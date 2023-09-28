//
//  GameKitHelper.swift
//  GameCenter
//
//  Created by Fabrício Masiero on 28/09/23.
//

import GameKit

class GameKitHelper: NSObject {
	
	static let shared: GameKitHelper = {
		let instance = GameKitHelper()
		return instance
	}()
	
	var authenticationViewController: UIViewController?
	
	func authenticateLocalPlayer() {
		authenticationViewController = nil
		GKLocalPlayer.local.authenticateHandler = { viewController, error in
			
			if let viewController = viewController {
				self.authenticationViewController = viewController
				NotificationCenter.default.post(name: .presentAuthenticationViewController, object: self)
				return
			}
			
			if error != nil {
				return
			}
		}
	}

	func submitScore(points: Int) {
		if #available(iOS 14.0, *) {
			GKLeaderboard.submitScore(points, context: 0, player: GKLocalPlayer.local, leaderboardIDs: ["MouseClimber.Leaderboard"]) { error in
				print(error ?? "Errou")
			}
		} else {
			print("iOS desatualizado")
		}
	}
	
	func retrieveLeaderboard(completion: @escaping (GKLeaderboard?) -> Void) {
//		var leaderboard: GKLeaderboard?
		
		if #available(iOS 14.0, *) {
			GKLeaderboard.loadLeaderboards(IDs: ["MouseClimber.Leaderboard"]) { (leaderboards, error) in
				if let leaderboards {
					completion(leaderboards.first)
				}
			}
		} else {
			// Fallback on earlier versions
		}
	}
}

extension Notification.Name {
	static let presentAuthenticationViewController =
	Notification.Name("presentAuthenticationViewController")
}
