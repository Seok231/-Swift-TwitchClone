//
//  FindCollectionCell.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/09/01.
//

import UIKit
import AVFoundation

class FindCollectionCell: UICollectionViewCell {

    @IBOutlet weak var hostImageView: UIImageView!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var liveView: UIImageView!
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    let liveResult = LiveResult()
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var liveListModel: LiveListModel? {
        didSet {
            settingPlayerURL()
            settingLabel()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        hostNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 15)
        hostNameLabel.textColor = .white
        categoryLabel.textColor = .lightGray
        titleLabel.textColor = .lightGray
        liveView.backgroundColor = .black
        hostImageView.layer.cornerRadius = hostImageView.frame.height/2
        thumbnailView.contentMode = .scaleAspectFill
        liveView.layer.cornerRadius = 5
        thumbnailView.layer.cornerRadius = 5
    }
    
    func livePlay() {
        if self.player.timeControlStatus != .playing {
            print("play")
            self.player.play()
            self.player.seek(to: .zero)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                self.thumbnailView.isHidden = true
            }
        }
    }
    
    func liveStop() {
        self.player.pause()
        thumbnailView.isHidden = false
    }
    
    private func settingPlayerURL() {
        if let hls = liveListModel?.hls {
            let url = liveResult.hlsURL(hls: hls)
            let playerItem = AVPlayerItem(url: url)
            playerItem.preferredForwardBufferDuration = TimeInterval(1.0)
            self.player = AVPlayer(playerItem: playerItem)
            self.playerLayer.player = self.player
            self.player.volume = 0
            self.playerLayer.frame = self.liveView.bounds
            self.playerLayer.videoGravity = .resizeAspectFill
            self.liveView.layer.addSublayer(self.playerLayer)
        }
    }
    
    private func settingLabel() {
        let name = liveListModel?.title
        let date = liveListModel?.date
        hostNameLabel.text = name
//        categoryLabel.text = date?.description
    }

}
