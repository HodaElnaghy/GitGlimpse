//
//  RepoTableViewCell.swift
//  GitGlimpse
//
//  Created by Hoda Elnaghy on 10/25/23.
//

import UIKit

class RepoTableViewCell: UITableViewCell {

    @IBOutlet weak var languageColorImage: UIImageView!
    @IBOutlet weak var ownerAvatarBackgroundView: UIView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var numberOfForksLabel: UILabel!
    @IBOutlet weak var repoCreationDate: UILabel!
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var ownerAvatar: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ownerAvatarBackgroundView.layer.cornerRadius = 25
        ownerAvatarBackgroundView.clipsToBounds = true
        ownerAvatarBackgroundView.dropShadow()
        
        ownerAvatar.layer.cornerRadius = 25
        ownerAvatar.clipsToBounds = true
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
