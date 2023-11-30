//
//  Dummy.swift
//  TwitchClone
//
//  Created by 양윤석 on 11/6/23.
//

import Foundation


// tableView 썸네일 생성 hls -> AVLayer or hls to image
//            if let hls = LiveList.result.liveList[indexPath.row].hls {
//                DispatchQueue.global().async {

//                    var player = AVPlayer()
            
//                    let item = AVPlayerItem(url: url)
//                    item.preferredForwardBufferDuration = TimeInterval(1.0)
//                    player = AVPlayer(playerItem: item)
//                    let playerLayer = AVPlayerLayer(player: player)
//                    playerLayer.frame = cell.thumbnailView.bounds
//                    playerLayer.videoGravity = .resize
//                    cell.thumbnailView.layer.addSublayer(playerLayer)

//                }
//            }
    
//            let testURL2 = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!
//            let testURL = URL(string: "http://diddbstjr55.shop/hls/yys.m3u8")!
//            let asset: AVAsset = AVAsset(url: testURL)
//            let generator = AVAssetImageGenerator(asset: asset)
//            generator.appliesPreferredTrackTransform = true
////                generator.maximumSize = CGSize(width: 300, height: 0)
////            generator.requestedTimeToleranceBefore = .zero
////            generator.requestedTimeToleranceAfter = CMTime(seconds: 2, preferredTimescale: 600)
//
//            let time = CMTime(seconds: 10, preferredTimescale: 600) // 10초 지점의 이미지 가져오기 (예시)
//
//            Task{
//                if #available(iOS 16, *) {
//
////                    let (image, actualTime) = try await generator.image(at: .zero)
//                    print("hls -> image")
//                    let image = try await generator.image(at: time).image
//                    let image2 = try generator.copyCGImage(at: time, actualTime: nil)
//                    cell.thumbnailView.image = UIImage(cgImage: image2)
////                            self.playListTableView.reloadData()
//                } else {
//                    print("you < iOS 16 ")
//                    // Fallback on earlier versions
//                }
//            }

//             1순위 cacheImage 2순위 영상링크
//            let hls = LiveList.result.liveList[indexPath.row].hls
//            let url = liveResult.hlsURL(hls: hls)
//            let cacheKey = NSString(string: url.description)
//            if let cacheImage = ImageCachManager.shared.object(forKey: cacheKey) {
//                cell.thumbnailView.contentMode = .scaleToFill
//                cell.thumbnailView.image = cacheImage
//                //                    playListTableView.reloadData()
//                print("cacheImage set")
//            }else {
//
//                DispatchQueue.main.async {
//
//                    var player = AVPlayer()
//                    let item = AVPlayerItem(url: url)
//                    item.preferredForwardBufferDuration = TimeInterval(1.0)
//                    player = AVPlayer(playerItem: item)
//                    let playerLayer = AVPlayerLayer(player: player)
//                    playerLayer.frame = cell.thumbnailView.bounds
//                    playerLayer.videoGravity = .resize
//                    cell.thumbnailView.layer.addSublayer(playerLayer)
//
//                }
//                self.generator = ACThumbnailGenerator(streamUrl: url)
//                self.generator.delegate = self
//
//                self.generator.captureImage(at: 300)
//                //                    playListTableView.reloadData()
//
//
//            }
