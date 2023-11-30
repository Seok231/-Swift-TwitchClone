//
//  LiveViewCell.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/08/28.
//

import UIKit
import GoogleSignIn
import Firebase
import FirebaseDatabase
import AVFoundation

class LiveViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var liveView: UIImageView!
    @IBOutlet weak var hostImage: UIImageView!
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var roomNameLabel: UILabel!
    let liveResult = LiveResult()
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var liveListModel: LiveListModel? {
        didSet {
            settingPlayerURL()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        liveView.backgroundColor = .black
        hostNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        roomNameLabel.font = UIFont.boldSystemFont(ofSize: 15)
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 10)
        hostNameLabel.textColor = .white
        roomNameLabel.textColor = .lightGray
        categoryLabel.textColor = .lightGray
        hostImage.layer.cornerRadius = hostImage.frame.height/2
        hostImage.contentMode = .scaleToFill
        thumbnailView.contentMode = .scaleAspectFill
    }

    func livePlay() {
        if self.player.timeControlStatus != .playing {
//            player.seekToLive()
            self.player.play()
            thumbnailView.isHidden = true
        }
    }
    
    func liveStop() {
        self.player.pause()
        if self.player.currentTime().seconds > 1 {
            thumbnailView.isHidden = true
        }else{
            thumbnailView.isHidden = false
        }
    }
    
    private func settingPlayerURL() {
        let hls = liveListModel?.hls ?? ""
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
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

extension AVPlayer {
    func seekToLive() {
        if let items = currentItem?.seekableTimeRanges, !items.isEmpty {
            let range = items[items.count - 1]
            let timeRange = range.timeRangeValue
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSeconds = CMTimeGetSeconds(timeRange.duration)
            seek(to: CMTimeMakeWithSeconds(startSeconds + durationSeconds, preferredTimescale: 1))
        }
    }
}
