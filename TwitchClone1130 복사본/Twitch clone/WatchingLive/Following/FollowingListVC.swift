//
//  FollowingListVC.swift
//  TwitchClone
//
//  Created by 양윤석 on 10/12/23.
//

import UIKit

class FollowingListVC: UIViewController {
    
    var followingListModel: CategoryModel? {
        didSet {
            categortFilter()
        }
    }
    var categoryList: [LiveListModel] = []
    var category: String?
    
    @IBOutlet weak var followingListTableView: UITableView!
    
    lazy var rightButton: UIBarButtonItem = {
            let button = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(buttonPressed(_:)))
            
            return button
        }()
    @objc private func buttonPressed(_ sender: Any) {
            if let button = sender as? UIBarButtonItem {
                switch button.tag {
                case 1:
                    // Change the background color to blue.
                    self.view.backgroundColor = .blue
                case 2:
                    // Change the background color to red.
                    self.view.backgroundColor = .red
                default:
                    print("error")
                }
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        followingListTableView.register(UINib(nibName: "FirstFollowingListTableViewCell", bundle: nil), forCellReuseIdentifier: "FirstFollowingListTableViewCell")
        followingListTableView.register(UINib(nibName: "LiveViewCell", bundle: nil), forCellReuseIdentifier: "LiveViewCell")
        followingListTableView.separatorStyle = .none
        followingListTableView.dataSource = self
        followingListTableView.delegate = self
        
        self.navigationItem.rightBarButtonItem = self.rightButton
        
    }
    
    func categortFilter() {
        guard let category = followingListModel?.name else { return }
        self.category = category
        for i in 0...LiveList.result.liveList.count-1 {
            if LiveList.result.liveList[i].streamCategory == category {
                self.categoryList.append(LiveList.result.liveList[i])
            }
        }
    }
}

extension FollowingListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categoryList.count+1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            return 150
        default :
            return 330
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            self.navigationItem.title = category
        }
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0{
            self.navigationItem.title = nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = followingListTableView.dequeueReusableCell(withIdentifier: "FirstFollowingListTableViewCell", for: indexPath) as! FirstFollowingListTableViewCell
            
            cell.categoryImageView.contentMode = .scaleToFill
            guard let imageURL = followingListModel?.url else {return cell}
            guard let categoryName = followingListModel?.name else {return cell}
            CasheImage.imageToDirectory(identifier: categoryName, imageURL: imageURL) { image in
                cell.categoryImageView.image = image
            }
            cell.titleLabel.text = categoryName
            cell.categoryImageView.layer.cornerRadius = 10
            cell.selectionStyle = .none
            cell.followingCategoryName = categoryName
            cell.testCategory = categoryName
            return cell
        default :
            let list = categoryList[indexPath.row-1]
            let cell = followingListTableView.dequeueReusableCell(withIdentifier: "LiveViewCell", for: indexPath) as! LiveViewCell
            cell.liveListModel = list
            cell.hostNameLabel.text = list.hostName
            cell.categoryLabel.text = list.streamCategory
            cell.roomNameLabel.text = list.title
            let hostImage = CasheImage.hostImage(stringURL: list.hostImage)
            let thumbnailImage = CasheImage.thumbnailImage(imageURL: list.imageURL)
            cell.hostImage.image = hostImage
            cell.thumbnailView.image = thumbnailImage
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            print("info")
        default :
            guard let playLiveVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayLiveVC") as? PlayLiveVC else { return }
            playLiveVC.modalTransitionStyle = .crossDissolve
            playLiveVC.modalPresentationStyle = .overFullScreen
            self.present(playLiveVC, animated: true, completion: nil)
            playLiveVC.liveListModel = categoryList[indexPath.row-1]
            
        }
    }
}

extension FollowingListVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print("y : ", scrollView.contentOffset.y)
        guard let visivleCells = followingListTableView.visibleCells as? [LiveViewCell] else{
            return
        }
        guard let firstCell = visivleCells.first else {
            return
        }
        if visivleCells.count == 1 {
            firstCell.livePlay()
            return
        }
        
        let secondCell = visivleCells[1]
        
        let firstCellPositionY = followingListTableView.convert(firstCell.frame.origin, to: self.view).y
//        print("firstCell", firstCellPositionY)
        if firstCellPositionY > -150 {
            
            firstCell.livePlay()
            var otherCells = visivleCells
            otherCells.removeFirst()
            otherCells.forEach { cell in
                cell.liveStop()
            }
//            firstCell.player.play()
        } else {
            secondCell.livePlay()
            var otherCells = visivleCells
            otherCells.remove(at: 1)
            otherCells.forEach { cell in
                cell.liveStop()
            }
        }
        
        
    }
}
