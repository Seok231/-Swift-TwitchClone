//
//  ChattingTableViewCell.swift
//  Twitch clone
//
//  Created by 양윤석 on 2023/08/17.
//

import UIKit

class ChattingTableViewCell: UITableViewCell {

    

    @IBOutlet weak var chatLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
