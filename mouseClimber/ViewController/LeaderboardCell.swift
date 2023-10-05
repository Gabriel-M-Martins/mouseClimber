//
//  LeaderboardCell.swift
//  mouseClimber
//
//  Created by Arthur Sobrosa on 05/10/23.
//

import UIKit

class LeaderboardCell: UITableViewCell {

    @IBOutlet var playerImage: UIImageView!
    @IBOutlet var playerName: UILabel!
    @IBOutlet var playerCheeses: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        playerImage.layer.cornerRadius = playerImage.frame.width / 2
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
