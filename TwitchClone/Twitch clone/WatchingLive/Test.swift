//
//  Test.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/09/25.
//

import UIKit
import AVFoundation

class Test: UIViewController {
    @IBOutlet weak var imageView: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        let testURL2 = URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_fmp4/master.m3u8")!
        let testURL = URL(string: "http://diddbstjr55.shop/hls/yys.m3u8")!
        let playerItem = AVPlayerItem(url: testURL2)
        let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
        playerItem.add(videoOutput)
        let player = AVPlayer(playerItem: playerItem)
        player.play()
        
        let time = playerItem.currentTime()
        guard let buffer = videoOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else {return}
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {return}
        imageView.image = UIImage(cgImage: cgImage)
        

    }
    
    func captureFrame(playerItem: AVPlayerItem, videoOutput: AVPlayerItemVideoOutput) -> UIImage? {
        let time = playerItem.currentTime()
        guard let buffer = videoOutput.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: nil) else {
            return nil
        }
        let ciImage = CIImage(cvPixelBuffer: buffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }

}

