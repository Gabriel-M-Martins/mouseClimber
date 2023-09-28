//
//  LeaderboardViewController.swift
//  mouseClimber
//
//  Created by Gabriel Medeiros Martins on 28/09/23.
//

import UIKit

class LeaderboardViewController: UIViewController {
    @IBOutlet weak var table: UITableView!
    
    private var entries: [(position: Int, player: String, score: String, img: UIImage?)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.dataSource = self
        
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
        let entry = entries[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
        
        cell.imageView?.image = entry.img
        cell.textLabel?.text = "\(entry.position + 1). \(entry.player)"
        cell.detailTextLabel?.text = entry.score
        
        cell.textLabel?.font = .systemFont(ofSize: 20)
        cell.detailTextLabel?.font = .systemFont(ofSize: 16)
        
        return cell
    }
    
    
}
