//
//  LeaderboardViewController.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 28/09/23.
//

import UIKit

class LeaderboardViewController: BackgroundViewController {
    @IBOutlet weak var table: UITableView!
    
    private var entries: [(position: Int, player: String, score: String, img: UIImage?)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        
        DispatchQueue.global().async { [weak self] in
            let dg = DispatchGroup()
            
            GameKitHelper.shared.retrieveLeaderboard { leaderboard in
                guard #available(iOS 14.0, *) else { return }
                guard let leaderboard = leaderboard else { return }
                
                dg.enter()
                leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(location: 1, length: 10), completionHandler: { _, scores, _, _ in
                    guard let scores = scores else { return }
                    
                    for (position, score) in scores.enumerated() {
                        dg.enter()
                        score.player.loadPhoto(for: .small) { img, _ in
                            self?.entries.append((position: position, player: score.player.alias, score: score.formattedScore, img))
                            dg.leave()
                        }
                    }
                    dg.leave()
                })
                
                dg.notify(queue: .main) {
                    self?.table.reloadData()
                }
            }
        }
    }
}

extension LeaderboardViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sortedEntries = entries.sorted { $0.position < $1.position }
        
        let entry = sortedEntries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath) as! LeaderboardCell
        
        cell.playerImage.image = entry.img
        cell.playerName.text = "\(entry.position + 1). \(entry.player)"
        cell.playerCheeses.text = entry.score
        
        cell.playerName.font = .systemFont(ofSize: 20)
        cell.playerCheeses.font = .systemFont(ofSize: 16)
        
        cell.playerName.textColor = .systemBackground
        cell.playerCheeses.textColor = .systemBackground
        
        return cell
    }
}

extension LeaderboardViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.table.deselectRow(at: indexPath, animated: true)
    }
}
