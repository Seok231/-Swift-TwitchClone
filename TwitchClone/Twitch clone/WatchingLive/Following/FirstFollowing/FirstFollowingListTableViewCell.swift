//
//  FirstFollowingListTableViewCell.swift
//  TwitchClone
//
//  Created by 양윤석 on 10/12/23.
//

import UIKit
import Firebase

class FirstFollowingListTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var followingBT: UIButton!
    @IBAction func followingBT(_ sender: Any) {
        setUserFollowing(category: followingCategoryName ?? "")
    }
    var followingBool = true
    var ref = Database.database().reference()
    var testCategory: String = ""
    override func awakeFromNib() {
        super.awakeFromNib()
        let fontSize = UIFont.boldSystemFont(ofSize: 30)
        titleLabel.font = fontSize
        titleLabel.textColor = .white
        followingBT.setTitle("팔로잉", for: .normal)
        followingBT.tintColor = .white
        followingBT.configuration?.imagePlacement = .top
        followingBT.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        
    }
    var followingCategoryName: String? {
        didSet{
//           setUserFollowing(category: followingCategoryName ?? "")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUserFollowing(category: String) {
        let userName = UserInfoModel.user.userEmailSplit
        if followingBool {
            followingBT.setImage(UIImage(systemName: "heart"), for: .normal)
            followingBool.toggle()
            ref.child("FirstTree/Users/\(userName)/following/category/\(category)").setValue(["following" : 0, "name" : category])

        } else {
            followingBT.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            followingBool.toggle()
            ref.child("FirstTree/Users/\(userName)/following/category/\(category)").setValue(["following" : 1, "name" : category])
        }
    }
    
}
