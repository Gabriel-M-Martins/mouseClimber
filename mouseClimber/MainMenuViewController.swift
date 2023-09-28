//
//  MainMenuViewController.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 28/09/23.
//

import UIKit

class MainMenuViewController: UIViewController {
    static let startGameSegue: String = "startGame"
    
    private var clickedStart = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Settings(view: self.view)
        
        validateGameCenter()
        loadTilesAssets()
    }

    @IBAction func startGame(_ sender: Any) {
        if Settings.hasFinishedLoadingTiles {
            enterGame()
        } else {
            clickedStart = true
        }
    }
    
    @IBAction func openLeaderboard(_ sender: Any) {
        performSegue(withIdentifier: "leaderboard", sender: nil)
    }
    
    private func enterGame() {
        clickedStart = false
        performSegue(withIdentifier: Self.startGameSegue, sender: nil)
    }
    
    private func validateGameCenter() {
        GameKitHelper.shared.authenticateLocalPlayer()
    }
    
    private func loadTilesAssets() {
        let dg = DispatchGroup()
        let queue = DispatchQueue(label: "TileAssetsLoader")
        
        queue.async {
            for i in ObstacleTiles.allCases {
                dg.enter()
                _ = i.texture(ofSize: CGSize(width: Settings.buildingTileSize, height: Settings.buildingTileSize))
                dg.leave()
            }
        }
        
        queue.async {
            for i in BuildingTiles.allCases {
                dg.enter()
                _ = i.texture(ofSize: CGSize(width: Settings.buildingTileSize, height: Settings.buildingTileSize))
                dg.leave()
            }
        }
        
        dg.notify(queue: queue) { [weak self] in
            Settings.hasFinishedLoadingTiles = true
            guard self != nil else { return }
            
            if self!.clickedStart {
                self!.enterGame()
            }
        }
    }
}
