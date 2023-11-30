//
//  SearchVC.swift
//  TwitchClone
//
//  Created by 양윤석 on 10/18/23.
//

import Foundation
import UIKit

class ResultsCell: UITableViewCell {
    
    @IBOutlet weak var resultsLabel: UILabel!
    
}

class SearchVC: UIViewController {
    
    @IBOutlet weak var searchTableView: UITableView!
    
//    var searchController: UISearchController!
//    var resultsController: SearchVC!
    var liveList = [LiveListModel]()
    let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        
        searchBar.placeholder = "검색"
        searchBar.delegate = self
//        let cancelBT = navigationItem.makeSFSymbolButton(self, action: #selector(cancelBT), symbolName: "xmark")
        navigationItem.titleView = searchBar
//        navigationItem.leftBarButtonItem = cancelBT
        searchTableView.register(UINib(nibName: "FollowingTableViewCell", bundle: nil), forCellReuseIdentifier: "FollowingTableViewCell")
        searchTableView.dataSource = self
        searchTableView.delegate = self
        let tapGesture = UIPanGestureRecognizer(target: self, action: #selector(tapTableView(sender: )))
        searchTableView.addGestureRecognizer(tapGesture)
    }
    
    @objc func tapTableView(sender: UIGestureRecognizer) {
        searchBar.resignFirstResponder()
    }
    
    @objc func cancelBT() {
        searchBar.resignFirstResponder()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchBar.resignFirstResponder()
        view.endEditing(true)
    }
}

extension SearchVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        liveList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if liveList.count == 0 {
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "ResultsCell", for: indexPath) as! ResultsCell
            cell.resultsLabel.text = "검색 결과가 없습니다."
            return cell
        } else {
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "FollowingTableViewCell", for: indexPath) as! FollowingTableViewCell
            let list = liveList[indexPath.row]
            cell.hostNameLabel.text = list.hostName
            cell.roomNameLabel.text = list.title
            cell.gameLabel.text = list.streamCategory
            let cacheKey = NSString(string: list.imageURL)
            CasheImage.thumbnailImage2(imageURL: list.imageURL) { image in
                cell.thumbnailView.image = image
            }
            let hostImage = CasheImage.hostImage(stringURL: list.hostImage)
            cell.hostImageView.image = hostImage
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchBar.resignFirstResponder()
        guard let playLiveVC = self.storyboard?.instantiateViewController(withIdentifier: "PlayLiveVC") as? PlayLiveVC else { return }
        playLiveVC.modalTransitionStyle = .crossDissolve
        playLiveVC.modalPresentationStyle = .overFullScreen
        self.present(playLiveVC, animated: true, completion: nil)
        playLiveVC.liveListModel = liveList[indexPath.row]
    }
}

extension SearchVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = nil

    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchText = searchBar.text ?? ""
        liveList = LiveList.result.liveList.filter { live in
            live.hostName.lowercased().contains(searchText.lowercased())
        }
        searchTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}

extension SearchVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        liveList = LiveList.result.liveList.filter { live in
            live.hostName.lowercased().contains(searchText.lowercased())
        }
        searchTableView.reloadData()
        print("liveList.count", liveList.count)
    }
}
