//
//  FirstTableViewCell.swift
//  Twitch clone
//
//  Created by 양윤석 on 2023/08/14.
//

import UIKit


class FollowingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var hostImageView: UIImageView!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var gameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let fontSize = UIFont.boldSystemFont(ofSize: 25)
        hostNameLabel.font = fontSize
        hostNameLabel.textColor = .white
        roomNameLabel.textColor = .gray
        gameLabel.textColor = .gray
        self.backgroundColor = .black
        hostImageView.layer.cornerRadius = hostImageView.frame.height/2
        hostImageView.image = UIImage(named: "loadingImage3")
        thumbnailView.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
//        if selected {
//                contentView.layer.borderWidth = 2
//                contentView.layer.borderColor = UIColor.darkGray.cgColor
//            } else {
//                contentView.layer.borderWidth = 2
//                contentView.layer.borderColor = UIColor.black.cgColor
//            }
    }
    
}
