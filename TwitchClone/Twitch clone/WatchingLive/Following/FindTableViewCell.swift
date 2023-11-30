//
//  FindTableViewCell.swift
//  TwitchClone
//
//  Created by 양윤석 on 2023/09/01.
//

import UIKit
import Foundation

protocol FindCollectionDelegate: AnyObject {
    func collectionView(collectionviewcell: FindCollectionCell?, index: Int, didTappedInTableViewCell: FindTableViewCell)
}

class FindTableViewCell: UITableViewCell {
    
    @IBOutlet weak var findTableCollectionView: UICollectionView!
    let liveResult = LiveResult()
    weak var cellDelegate: FindCollectionDelegate?
    var generator: ACThumbnailGenerator!
    var cellIndex: Int = 0

    private enum Const {
        static let itemSize = CGSize(width: 300, height: 250)
        static let itemSpacing = 24.0
        static var insetX: CGFloat {
            (UIScreen.main.bounds.width - Self.itemSize.width) / 2.0
        }
        static var collectionViewContentInset: UIEdgeInsets {
            UIEdgeInsets(top: 0, left: self.insetX, bottom: 0, right: self.insetX)
        }
    }
    
    private let collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = Const.itemSize
        layout.minimumLineSpacing = Const.itemSpacing
        layout.minimumInteritemSpacing = 0
        return layout
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        findTableCollectionView.register(UINib(nibName: "FindCollectionCell", bundle: nil), forCellWithReuseIdentifier: "FindCollectionCell")
        findTableCollectionView.dataSource = self
        findTableCollectionView.delegate = self
        findCollectionViewInit()
    }
    
    private func findCollectionViewInit() {
        self.findTableCollectionView.collectionViewLayout = self.collectionViewFlowLayout
        self.findTableCollectionView.isScrollEnabled = true
        self.findTableCollectionView.showsLargeContentViewer = false
        self.findTableCollectionView.showsVerticalScrollIndicator = true
        self.findTableCollectionView.clipsToBounds = true
        self.findTableCollectionView.isPagingEnabled = false // scrollViewWillEndDragging
        self.findTableCollectionView.contentInsetAdjustmentBehavior = .never // safe area에 의해 가려지는 것 방지 inset 조정 비활성화
        self.findTableCollectionView.showsHorizontalScrollIndicator = false // 스크롤 바
        self.findTableCollectionView.contentInset = Const.collectionViewContentInset
        self.findTableCollectionView.decelerationRate = .fast
        self.findTableCollectionView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
}

extension FindTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        LiveList.result.liveList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let cell = findTableCollectionView.dequeueReusableCell(withReuseIdentifier: "FindCollectionCell", for: indexPath) as! FindCollectionCell
        
        let cell2 = findTableCollectionView.cellForItem(at: indexPath) as! FindCollectionCell
        print("didEndDisplaying")
        cell2.liveStop()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = findTableCollectionView.dequeueReusableCell(withReuseIdentifier: "FindCollectionCell", for: indexPath) as! FindCollectionCell
        let list = LiveList.result.liveList[indexPath.item]
        cell.liveListModel = list
        
        // 화면에 보이는 셀 Play
        if self.cellIndex == indexPath.item  {
            cell.livePlay()
        }
        
        CasheImage.thumbnailImage2(imageURL: list.imageURL) { image in
            cell.thumbnailView.image = image
        }
        let hostImage = CasheImage.hostImage(stringURL: list.hostImage)
        cell.hostImageView.image = hostImage
        cell.categoryLabel.text = list.streamCategory
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = findTableCollectionView.cellForItem(at: indexPath) as? FindCollectionCell
        // table cell 안 collection cell 눌린 정보 가져오기
        self.cellDelegate?.collectionView(collectionviewcell: cell, index: indexPath.item, didTappedInTableViewCell: self)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let scrolledOffsetX = targetContentOffset.pointee.x + scrollView.contentInset.left
        let cellWidth = Const.itemSize.width + Const.itemSpacing
        let index = Int(round(scrolledOffsetX / cellWidth))
        targetContentOffset.pointee = CGPoint(x: Double(index) * cellWidth - scrollView.contentInset.left, y: scrollView.contentInset.top)
        self.findTableCollectionView.reloadData()
        self.cellIndex = index
    }
}

