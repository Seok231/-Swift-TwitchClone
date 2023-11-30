//
//  LiveChatTableViewCell.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/09/13.
//

import UIKit

class LiveChatTableViewCell: UITableViewCell {

    @IBOutlet weak var chatLabelCoverView: UIView!
    @IBOutlet weak var chatLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.backgroundColor = (UIColor.black.cgColor).copy(alpha: 0.6)
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
}
