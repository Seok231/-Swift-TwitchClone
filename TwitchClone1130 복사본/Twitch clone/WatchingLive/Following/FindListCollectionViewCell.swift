//
//  FindListCollectionViewCell.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/09/29.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseDatabase

class FindListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var listImageView: UIImageView!
    @IBOutlet weak var hostImageView: UIImageView!
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var roomNameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()

        hostNameLabel.textColor = .white
        categoryLabel.textColor = .lightGray
        roomNameLabel.textColor = .lightGray
        hostNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 10)
        roomNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        hostImageView.layer.cornerRadius = 25
        hostImageView.contentMode = .scaleToFill
        listImageView.contentMode = .scaleAspectFill
        listImageView.backgroundColor = .black
        listImageView.image = UIImage(named: "loadingImage3")
    }

}
