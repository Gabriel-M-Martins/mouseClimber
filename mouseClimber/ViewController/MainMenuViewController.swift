//
//  MainMenuViewController.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 28/09/23.
//

import UIKit

class MainMenuViewController: BackgroundViewController {
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var leaderboardButton: UIButton!
    @IBOutlet var creditsButton: UIButton!
    
    static let startGameSegue: String = "startGame"
    static let openLeaderboardSegue: String = "openLeaderboard"
    static let showCreditsSegue: String = "showCredits"
    static let goToOnboarding: String = "goToOnboarding"
    
    private var clickedStart = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = Settings(view: self.view)
        
        validateGameCenter()
        loadTilesAssets()
        
        let customFontSize: CGFloat = 20
        
        guard let customFont = UIFont(name: "IrishGrover-Regular", size: customFontSize) else {
            fatalError("Failed to load custom font.")
        }
        
        startButton.titleLabel?.font = customFont
        startButton.tintColor = .systemBackground
        
        leaderboardButton.titleLabel?.font = customFont
        leaderboardButton.tintColor = .systemBackground
        
        creditsButton.titleLabel?.font = customFont
        creditsButton.tintColor = .systemBackground
        
        if !UserDefaults.hasOnboarded {
            performSegue(withIdentifier: Self.goToOnboarding, sender: nil)
        }
    }
    
    @IBAction func showCredits(_ sender: Any) {
        performSegue(withIdentifier: Self.showCreditsSegue, sender: nil)
    }
    
    @IBAction func startGame(_ sender: Any) {
        if Settings.hasFinishedLoadingTiles {
            enterGame()
        } else {
            clickedStart = true
        }
    }
    
    @IBAction func openLeaderboard(_ sender: Any) {
        performSegue(withIdentifier: Self.openLeaderboardSegue, sender: nil)
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
