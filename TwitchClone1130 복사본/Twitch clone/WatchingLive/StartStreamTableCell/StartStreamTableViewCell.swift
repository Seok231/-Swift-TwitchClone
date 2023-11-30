//
//  StartStreamTableViewCell.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/09/15.
//

import UIKit

class StartStreamTableViewCell: UITableViewCell {

    @IBOutlet weak var labelBackView: UIView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = .clear
        labelBackView.layer.cornerRadius = 10
        labelBackView.backgroundColor = .darkGray
        let fontSize25 = UIFont.boldSystemFont(ofSize: 30)
        let fontSize15 = UIFont.boldSystemFont(ofSize: 15)
        
        mainLabel.textColor = .white
        mainLabel.font = fontSize25
        
        subLabel.textColor = .white
        subLabel.font = fontSize15
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
