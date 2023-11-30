//
//  StreamCam.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/09/08.
//

import Foundation
import UIKit
import AVFoundation
import HaishinKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Logboard
import VideoToolbox

class StreamCam: UIViewController {
    
    @IBOutlet weak var fpsSGControl: UISegmentedControl!
    @IBOutlet weak var fpsSettingView: UIView!
    @IBOutlet weak var categoryInfoView: UIView!
    @IBOutlet weak var categoryImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var streamOnOffLabel: UILabel!
    @IBOutlet weak var streamOnOffUnderLabel: UILabel!
    @IBOutlet weak var streamTimeLabel: UILabel!
    @IBOutlet weak var streamTimeUnderLabel: UILabel!
    @IBOutlet weak var backBT: UIButton!
    @IBOutlet var camLiveView: MTHKView!
    @IBOutlet weak var infoSettingBT: UIButton!
    @IBOutlet weak var liveChatTableView: UITableView!
    @IBOutlet weak var pushStreamBT: UIButton!
    @IBOutlet weak var muteMicBT: UIButton!
    @IBOutlet weak var changePositionBT: UIButton!
    @IBOutlet weak var optionBTStackView: UIStackView!
    @IBOutlet weak var streamInfoView: UIView!
    let ref = Database.database().reference()
    var storage = Storage.storage()
    var chattingList: [ChattingUpdate] = []
    let userName = UserInfoModel.user.userName
    let userEmail = UserInfoModel.user.userEmail
    let userEmailSplit = UserInfoModel.user.userEmailSplit
    let userPhotoURL = UserInfoModel.user.userPhotoURL
    var uploadCategory: String?
    let captureSession = AVCaptureSession()
    var rtmpConnection = RTMPConnection()
    var rtmpStream: RTMPStream! = nil
    var currentPosition: AVCaptureDevice.Position = .back
    var generator: ACThumbnailGenerator!
    var timer: Timer?
    var recognizerScale: CGFloat = 1.0
    var maxScale: CGFloat = 2.0
    var minScale: CGFloat = 1.0
    var uploadTitle = "\(UserInfoModel.user.userName)님의 방송"
    var uploadNotification = "\(UserInfoModel.user.userName)님이 방송을 시작하였습니다."
    var multiCamSetting = UserDefaults.standard.bool(forKey: "multiCamToggle")
    var fpsSettingViewShow: Bool = false
    private var fps = 0
    private var deviceOrientation = UIDeviceOrientation.portrait
    private var pushStreamBool: Bool = false
    private var retryCount: Int = 0
    private let maxRetryCount: Int = 5
    private var pipIntentView = UIView()
    @IBAction func categorySetting(_ sender: Any) {
        guard let liveSettingVC = self.storyboard?.instantiateViewController(withIdentifier: "LiveSettingVC") as? LiveSettingVC else { return }
//        liveSettingVC.modalTransitionStyle = .crossDissolve
        liveSettingVC.modalPresentationStyle = .automatic
        liveSettingVC.delegate = self
        liveSettingVC.settingBTBool = true
        self.present(liveSettingVC, animated: true, completion: nil)
    }
    
    @IBAction func settingBT(_ sender: Any) {
        if fpsSettingViewShow {
            fpsSettingView.isHidden = true
            fpsSettingViewShow.toggle()
        } else {
            fpsSettingView.isHidden = false
            fpsSettingViewShow.toggle()
        }
    }
    @IBAction func changePosition(_ sender: Any) {
        changePosition()
    }
    @IBAction func backBT(_ sender: Any) {
        self.dismiss(animated: true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("UIDeviceOrientationDidChangeNotification"), object: nil)
        rtmpStream.close()
        rtmpStream.attachAudio(nil)
        rtmpStream.attachCamera(nil)
        if #available(iOS 13.0, *) {
            rtmpStream.attachMultiCamera(nil)
        }
        timer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkCameraPermissions()
        requestAudioPermission()
    }
    
    override func viewDidLoad() {
        print("multiCamSetting ", multiCamSetting)
        chattingUpdate()
        setLayout()
        streamOnOfSetting()
        streamSetting()
        categoryInfoUpdate()
    }
    
    @objc func fpsSetting(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            rtmpStream.frameRate = 30
        } else {
            rtmpStream.frameRate = 60
        }
    }
    func changePosition() {
        let position: AVCaptureDevice.Position = currentPosition == .back ? .front : .back
        rtmpStream.attachCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position))
        if #available(iOS 13.0, *), multiCamSetting {
            rtmpStream.attachMultiCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentPosition))
        }
        currentPosition = position
    }
    
    func categoryInfoUpdate() {
        if let title = UserDefaults.standard.string(forKey: "title"), let categoryName = UserDefaults.standard.string(forKey: "category"), let categoryImage = UserDefaults.standard.string(forKey: "categoryImage"), let notification = UserDefaults.standard.string(forKey: "notification")   {
            print("categoryInfoUpdate", categoryName, categoryName, notification)
            categoryLabel.text = categoryName
            titleLabel.text = title
            self.uploadTitle = title
            self.uploadCategory = categoryName
            self.uploadNotification = notification
            categoryImageView.contentMode = .scaleAspectFill
            CasheImage.imageToDirectory(identifier: categoryName, imageURL: categoryImage) { image in
                self.categoryImageView.image = image
            }
//            let cacheKey = NSString(string: categoryImage)
//            if let cachedImage = ImageCachManager.shared.object(forKey: cacheKey){
//                categoryImageView.contentMode = .scaleAspectFill
//                categoryImageView.image = cachedImage
//            } else {
//                let refS = storage.reference(forURL: categoryImage)
//                refS.getData(maxSize: 10 * 1024 * 1024) { data, error in
//                    guard let image = UIImage(data: data!) else{return}
//                    self.categoryImageView.image = image
//                    ImageCachManager.shared.setObject(image, forKey: cacheKey)
//                }
//            }
        }
    }
    
    func setLayout() {
        optionBTStackView.layer.backgroundColor = (UIColor.black.cgColor).copy(alpha: 0.6)
        optionBTStackView.layer.cornerRadius = 10
        backBT.tintColor = .white
        backBT.layer.backgroundColor = (UIColor.black.cgColor).copy(alpha: 0.6)
        backBT.layer.cornerRadius = backBT.frame.height / 2
        streamInfoView.layer.backgroundColor = (UIColor.black.cgColor).copy(alpha: 0.6)
        streamInfoView.layer.cornerRadius = 10
        categoryInfoView.layer.backgroundColor = (UIColor.black.cgColor).copy(alpha: 0.6)
        categoryInfoView.layer.cornerRadius = 10
        categoryImageView.layer.cornerRadius = 10
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 15)
        categoryLabel.textColor = .lightGray
        fpsSettingView.layer.cornerRadius = 10
        fpsSettingView.layer.backgroundColor = (UIColor.black.cgColor).copy(alpha: 0.6)
        fpsSettingView.isHidden = true
        fpsSGControl.addTarget(self, action: #selector(fpsSetting(_:)), for: .valueChanged)
        
        liveChatTableView.backgroundColor = .clear
        liveChatTableView.register(UINib(nibName: "LiveChatTableViewCell", bundle: nil), forCellReuseIdentifier: "LiveChatTableViewCell")
        liveChatTableView.separatorStyle = .none
        liveChatTableView.frame = camLiveView.bounds
        liveChatTableView.transform = CGAffineTransformMakeScale(1, -1)
        liveChatTableView.dataSource = self
        liveChatTableView.delegate = self
        
        infoSettingBT.tintColor = .white
        streamOnOffLabel.text = "오프라인"
        streamOnOffLabel.textColor = .white
        streamOnOffLabel.layer.cornerRadius = 20
        streamOnOffUnderLabel.text = "방송"
        streamOnOffUnderLabel.textColor = .lightGray
        streamTimeLabel.text = "--"
        streamTimeLabel.textColor = .white
        streamTimeUnderLabel.text = "FPS"
        streamTimeUnderLabel.textColor = .lightGray
    }
    
    private func setPipIntentView() {
        pipIntentView.layer.borderWidth = 1.0
        pipIntentView.layer.borderColor = UIColor.white.cgColor
        pipIntentView.frame = .init(origin: CGPoint(x: 100, y: 755), size: .init(width: 250, height: 250))
        pipIntentView.isUserInteractionEnabled = true
        view.addSubview(pipIntentView)
//        let gesture = UIPanGestureRecognizer(target: self, action: #selector(draggingView))
//        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(doPinch(_:)))
//        pipIntentView.addGestureRecognizer(gesture)
//        pipIntentView.addGestureRecognizer(pinch)
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
////        rtmpStream.frameRate = 60
//        if touch.view == pipIntentView {
//            let destLocation = touch.location(in: view)
//            let prevLocation = touch.previousLocation(in: view)
//            var currentFrame = pipIntentView.frame
//            let deltaX = destLocation.x - prevLocation.x
//            let deltaY = destLocation.y - prevLocation.y
//            currentFrame.origin.x += deltaX
//            currentFrame.origin.y += deltaY
//            pipIntentView.frame = currentFrame
//            rtmpStream.multiCamCaptureSettings = MultiCamCaptureSettings(
//                mode: .pip,
//                cornerRadius: 10,
//                regionOfInterest: currentFrame,
//                direction: .south)
//        }
//    }
    
//    @objc func draggingView(_ sender: UIPanGestureRecognizer) {
//        let point = sender.location(in: view)
//        pipIntentView.center = point
//        let translation = sender.translation(in: self.view)
//        pipIntentView.center = CGPoint(x: pipIntentView.center.x + translation.x, y: pipIntentView.center.y + translation.y)
//        sender.setTranslation(CGPoint.zero, in: self.view)
//        rtmpStream.multiCamCaptureSettings = MultiCamCaptureSettings(
//            mode: .pip,
//            cornerRadius: 16.0,
//            regionOfInterest: pipIntentView.frame,
//            direction:  ImageTransform.east)
//    }
    
//    @objc func doPinch(_ pinch: UIPinchGestureRecognizer) {
//        if pinch.state == .began || pinch.state == .changed {
//            if(recognizerScale < maxScale && pinch.scale > 1.0) {
//                pipIntentView.transform = (pipIntentView.transform).scaledBy(x: pinch.scale, y: pinch.scale)
//                recognizerScale *= pinch.scale
//                pinch.scale = 1.0
//            }
//            else if (recognizerScale > minScale && pinch.scale < 1.0) {
//                pipIntentView.transform = (pipIntentView.transform).scaledBy(x: pinch.scale, y: pinch.scale)
//                recognizerScale *= pinch.scale
//                pinch.scale = 1.0
//            }
//        }
//        rtmpStream.multiCamCaptureSettings = MultiCamCaptureSettings(
//            mode: .pip ,
//            cornerRadius: 15,
//            regionOfInterest: pipIntentView.frame,
//            direction: .north)
//    }
    
    func streamSetting() {
        rtmpStream = RTMPStream(connection: rtmpConnection)
        rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            print("attachAudio error", error)
        }
        rtmpStream.attachCamera(AVCaptureDevice.default(for: .video)) {
            error in
            print("attachCamera error", error)
        }
        if #available(iOS 13.0, *) {
            if multiCamSetting {
                rtmpStream.attachMultiCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front))
            } else {
                rtmpStream.attachMultiCamera(AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back))
            }
        }
        rtmpStream.videoSettings = VideoCodecSettings(
            videoSize: .init(width: 854, height: 480),
            profileLevel: kVTProfileLevel_H264_Baseline_5_0 as String,
            bitRate: 640 * 1000,
            maxKeyFrameIntervalDuration: 2,
            scalingMode: .trim,
            bitRateMode: .average,
            allowFrameReordering: true ,
            isHardwareEncoderEnabled: true
        )
        NotificationCenter.default.addObserver(self, selector: #selector(self.detectOrientation), name: NSNotification.Name("UIDeviceOrientationDidChangeNotification"), object: nil)
        rtmpStream.addObserver(self, forKeyPath: "currentFPS", options: .new, context: nil)
        detectOrientation()
        camLiveView.videoGravity = .resizeAspectFill
        camLiveView?.attachStream(rtmpStream)
        
    }
    
    @objc func detectOrientation() {
        // 기기방향 가로
        if (UIDevice.current.orientation == .landscapeLeft) || (UIDevice.current.orientation == .landscapeRight) {
            deviceOrientation = UIDeviceOrientation.landscapeLeft
            rtmpStream.videoSettings = VideoCodecSettings(
                videoSize: .init(width: 1280, height: 720))
            if multiCamSetting {
                rtmpStream.multiCamCaptureSettings = MultiCamCaptureSettings(
                    mode: .pip,
                    cornerRadius: 16.0,
                    //regionOfInterest: .init(x: 590, y: 75, width: 250, height: 250)
                    regionOfInterest: .init(x: 90, y: 350, width: 250, height: 250)
                    , direction: .east )
            }
            if self.fps > 0{
                rtmpStream.close()
                rtmpStream.publish(userEmailSplit)
            }
        }
        //기기방향 세로
        else if (UIDevice.current.orientation == .portrait) || (UIDevice.current.orientation == .portraitUpsideDown) {
            deviceOrientation = UIDeviceOrientation.portrait
            rtmpStream.videoSettings = VideoCodecSettings(
                videoSize: .init(width: 720, height: 1280))
            if multiCamSetting {
                rtmpStream.multiCamCaptureSettings = MultiCamCaptureSettings(
                    mode: .pip, cornerRadius: 16.0,
                    // .init(x: 100, y: 780, width: 250, height: 250)
                    regionOfInterest: .init(x: 120, y: 330, width: 250, height: 250) , direction: .east)
            }
            if self.fps > 0{
                rtmpStream.close()
                rtmpStream.publish(userEmailSplit)
            }
        }
        if let orientation = DeviceUtil.videoOrientation(by: UIDevice.current.orientation) {
            rtmpStream.videoOrientation = orientation
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if Thread.isMainThread {
            self.fps = Int(rtmpStream.currentFPS)
            streamTimeLabel?.text = "\(fps.description)"
            if fps > 0 {
                streamOnOffLabel.text = "온라인"
                streamOnOffLabel.textColor = .red
            } else {
                streamOnOffLabel.text = "연결오류"
            }
        }
    }
    
    @IBAction func pushStream(_ sender: UIButton) {
        pushStreamBool.toggle()
        if UserDefaults.standard.string(forKey: "title") != nil,  UserDefaults.standard.string(forKey: "category") != nil, UserDefaults.standard.string(forKey: "categoryImage") != nil, UserDefaults.standard.string(forKey: "notification") != nil {
            streamOnOfSetting()
        } else {
            guard let liveSettingVC = self.storyboard?.instantiateViewController(withIdentifier: "LiveSettingVC") as? LiveSettingVC else{return}
            liveSettingVC.delegate = self
            self.present(liveSettingVC, animated: true, completion: nil)
        }
    }
    
    func streamOnOfSetting() {
        if self.pushStreamBool == true {
            startStream()
            pushStreamBT.tintColor = .red
            pushStreamBT.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            backBT.isHidden = true
            categoryInfoView.isHidden = true
        } else {
            pushStreamBT.tintColor = .white
            pushStreamBT.setImage(UIImage(systemName: "record.circle"), for: .normal)
            stopStream()
            backBT.isHidden = false
            categoryInfoView.isHidden = false
            streamOnOffLabel.text = "오프라인"
            streamOnOffLabel.textColor = .white
        }
    }
    
    func createThumbnail()  {
        let liveResult = LiveResult()
        let url = liveResult.hlsURL(hls: userEmailSplit )
        generator = ACThumbnailGenerator(streamUrl: url)
        generator.delegate = self
        generator.captureImage(at: 30)
        let cacheKey = NSString(string: url.description)
        print("cacheKey", url.description)
        if let cacheImage = ImageCachManager.shared.object(forKey: cacheKey) {
            timer?.invalidate()
            print("timer ?.invalidate()")
            FirebaseStorageManager.uploadImage(image: cacheImage, imageName: userEmailSplit) { URL in
                if let url = URL {
                    self.uploadFirebase(imageURL: url.description)
                }
            }
        }
    }
    
    func uploadFirebase(imageURL: String) {
        guard let userPhoto = userPhotoURL?.description else {return}
        guard let uploadCategory = self.uploadCategory else {return}
        ref.child("FirstTree/LiveList/\(userEmailSplit)/").setValue(["date" : Int(Date().timeIntervalSince1970), "hls" : userEmailSplit, "title" : uploadTitle, "hostName" : userEmailSplit, "imageURL" : imageURL, "streamCategory" : uploadCategory, "hostImage" :  userPhoto])
    }
    
    func startStream() {
        rtmpConnection.connect("rtmp://diddbstjr55.shop/hls")
        rtmpStream.publish(userEmailSplit)
        rtmpConnection.addEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        if rtmpStream.receiveVideo == true {
            var count = 0
            timer = Timer(timeInterval: 1, repeats: true, block: { _ in
                count += 1
                if  count > 4 {
                    self.createThumbnail()
                    count = 0
                }
            })
            RunLoop.current.add(timer!, forMode: .common)
        }
    }
    
    func stopStream() {
        rtmpConnection.close()
        rtmpConnection.removeEventListener(.rtmpStatus, selector: #selector(rtmpStatusHandler), observer: self)
        FirebaseStorageManager.deleteImage(imageName: userEmailSplit)
        timer?.invalidate()
        ref.child("FirstTree/LiveList/\(userEmailSplit)").removeValue()
    }
    
    @objc
    private func rtmpStatusHandler(_ notification: Notification) {
        let e = Event.from(notification)
        guard let data: ASObject = e.data as? ASObject, let code: String = data["code"] as? String else {
            return
        }
        switch code {
        case RTMPConnection.Code.connectSuccess.rawValue:
            retryCount = 0
            rtmpStream.publish(userEmailSplit)
        case RTMPConnection.Code.connectFailed.rawValue, RTMPConnection.Code.connectClosed.rawValue:
            guard retryCount <= maxRetryCount else {
                return
            }
            Thread.sleep(forTimeInterval: pow(2.0, Double(retryCount)))
            rtmpConnection.connect("rtmp://diddbstjr55.shop/hls")
            retryCount += 1
        default:
            break
        }
    }
    
    @IBAction func muteMic(_ sender: UIButton) {
        rtmpStream.hasAudio.toggle()
        let bool = rtmpStream.hasAudio
        if bool == true {
            muteMicBT.tintColor = .white
        } else {
            muteMicBT.tintColor = .red
        }
    }
    
    func chattingUpdate() {
        ref.child("FirstTree/LiveList/\(userEmailSplit)/chatList/").observe(DataEventType.value) { DataSnapshot in
            guard let snapData = DataSnapshot.value as? [String:Any] else{return}
            let data = try! JSONSerialization.data(withJSONObject: Array(snapData.values), options: [])
            do {
                let decoder = JSONDecoder()
                self.chattingList = try decoder.decode([ChattingUpdate].self, from: data)
                self.chattingList = self.chattingList.sorted(by: {$0.date > $1.date})
            } catch let error {
                print("get Firebase data error", error)
            }
            DispatchQueue.main.async {
                self.liveChatTableView.reloadData()
            }
        }
    }
    
    func requestAudioPermission(){
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: { (granted: Bool) in
            if granted {
                print("Audio: 권한 허용")
            } else {
                print("Audio: 권한 거부")
            }
        })
    }
    func checkCameraPermissions() {
        let cameraAuthStatus =  AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch cameraAuthStatus {
        case .authorized:
            return
        case .denied:
            abort()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler:{ (authorized) in
                if(!authorized){ abort() }
            })
        case .restricted:
            abort()
        @unknown default:
            fatalError()
        }
    }
}

extension StreamCam: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chattingList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = liveChatTableView.dequeueReusableCell(withIdentifier: "LiveChatTableViewCell", for: indexPath) as! LiveChatTableViewCell
        let sender = chattingList[indexPath.row].sender
        let body = chattingList[indexPath.row].body
        let senderBody = "\(sender) : \(body)"
        let attributedStr = NSMutableAttributedString(string: senderBody)
        
        // senderBody의 sender : range를 회색으로
        attributedStr.addAttribute(.foregroundColor, value: UIColor.lightGray, range: (senderBody as NSString).range(of: sender + " :"))
        cell.chatLabel.attributedText = attributedStr
        cell.backgroundColor = .clear
        cell.chatLabel.textAlignment = .right
        cell.chatLabel.sizeToFit()
        cell.chatLabelCoverView.layer.backgroundColor = (UIColor.black.cgColor).copy(alpha: 0.6)
        cell.chatLabelCoverView.layer.cornerRadius = 10
        cell.contentView.transform = CGAffineTransformMakeScale(1, -1)
        return cell
    }
}

extension StreamCam: ACThumbnailGeneratorDelegate {
    func generator(_ generator: ACThumbnailGenerator, didCapture image: UIImage, at position: Double) {
        let url = generator.streamUrl
        print("image to",url)
        let cacheKey = NSString(string: url.description)
        ImageCachManager.shared.setObject(image, forKey: cacheKey)
    }
}

extension StreamCam: LiveSettingVCProtocol {
    func didFinish(categoryName: String, categoryImage: String, title: String, notificationText: String) {
        categoryLabel.text = categoryName
        titleLabel.text = title
        self.uploadTitle = title
        self.uploadCategory = categoryName
        self.uploadNotification = notificationText
        categoryImageView.contentMode = .scaleAspectFill
        CasheImage.imageToDirectory(identifier: categoryName, imageURL: categoryImage) { image in
            self.categoryImageView.image = image
        }
        
    }
    
}
