//
//  ListViewController.swift
//  KaraokeScore
//
//  Created by Eiji Shiba on 2021/10/01.
//

import UIKit
import Foundation
import Cartography
import Alamofire
import Alertift

class AddViewController: UIViewController,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource {
    
    var tableView: UITableView?
    
    var searchBar: UISearchBar!
    var MusicArray: [MusicInfoModel] = []
    let activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //NavigationBarに検索バーを設置
        setSearchBar()
        
        activityIndicatorView.center = view.center
        activityIndicatorView.style = .large
        activityIndicatorView.color = .gray
        self.navigationController?.view.addSubview(activityIndicatorView)
        
        self.tableView = {
            let tableView = UITableView(frame: self.view.bounds, style: .plain)
            tableView.autoresizingMask = [
                .flexibleWidth,
                .flexibleHeight
            ]
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(MusicCustomCell.self, forCellReuseIdentifier: "Cell")
            self.view.addSubview(tableView)
            
            return tableView
            
        }()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //検索バーの設置
    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            //NavigationBarに適したサイズの検索バーを設置
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            //デリゲート
            searchBar.delegate = self
            //プレースホルダー
            searchBar.placeholder = "曲を検索"
            //検索バーのスタイル
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            //NavigationTitleが置かれる場所に検索バーを設置
            navigationItem.titleView = searchBar
            //NavigationTitleのサイズを検索バーと同じにする
            navigationItem.titleView?.frame = searchBar.frame
        }
    }
    
    //検索バーで入力する時
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        //キャンセルボタンを表示
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    //検索バーのキャンセルがタップされた時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //キャンセルボタンを非表示
        searchBar.showsCancelButton = false
        //キーボードを閉じる
        searchBar.resignFirstResponder()
    }
    
    //検索バーでEnterが押された時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.activityIndicatorView.startAnimating()
        searchBar.resignFirstResponder()
        let value = searchBar.text as! String
        
        self.fetchTrack(text: value, completion: { tracks in
            print(tracks[0].trackName)
            self.MusicArray = tracks
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                self.tableView?.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                self.activityIndicatorView.stopAnimating()
            }
        })
    }
    
    //曲検索
    public func fetchTrack(text: String, completion: @escaping (([MusicInfoModel]) -> Void)) {
        let newStr = text.replacingOccurrences(of: " ", with: "+")
        var compornent = URLComponents(string: "https://itunes.apple.com/search")!
        compornent.queryItems = [
            URLQueryItem(name: "term", value: newStr),
            URLQueryItem(name: "media", value: "music"),
            URLQueryItem(name: "country", value: "JP")
        ]
        let task = URLSession.shared.dataTask(with: compornent.url!) { (data, _, error) in
            if error == nil, let data = data {
                do {
                    let datas = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! NSDictionary
                    let tracks = datas.object(forKey: "results") as! [[String: AnyObject]]
                    if tracks.count > 0 {
                        let trackDatas = tracks.map{ MusicInfoModel(trackViewUrl: $0["trackViewUrl"] as? String ?? "",collectionId: $0["collectionId"] as? Int ?? 0, trackId: $0["trackId"] as? Int ?? 0, artistName: $0["artistName"] as? String ?? "", trackName: $0["trackName"] as? String ?? "", collectionName: $0["collectionName"] as? String ?? "", artworkUrl100: $0["artworkUrl100"] as? String ?? "", releaseDate: $0["releaseDate"] as? String ?? "", primaryGenreName: $0["primaryGenreName"] as? String ?? "", scoredate: Date(), score: 0) }
                        completion(trackDatas)
                    }
                    else{
                        DispatchQueue.main.async {
                            self.activityIndicatorView.stopAnimating()
                            Alertift.alert(title: "検索結果が見つかりませんでした", message: "他の検索ワードを入力してください。")
                                .action(.default("OK")) { [unowned self] in
                                }
                                .show(on: self)
                        }
                    }
                    
                } catch let error {
                    print("errorrrr",error)
                }
            }
        }
        task.resume()
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        var item = self.MusicArray[indexPath.row]
        let alert: UIAlertController = UIAlertController(title: "確認", message: "操作する選択肢をタップしてください", preferredStyle:  UIAlertController.Style.actionSheet)
        let defaultAction: UIAlertAction = UIAlertAction(title: "スコアを記録する", style: UIAlertAction.Style.default, handler:{
            //スコア記録
            (action: UIAlertAction!) -> Void in
            let next = RecordViewController()
            
            if let data = UserDefaults.standard.value(forKey:"musicinfokey") as? Data {
                var value = try? PropertyListDecoder().decode(Array<MusicInfoModel>.self, from: data)
                if value != nil {
                    for i in 0..<value!.count{
                        if value![i].trackId == item.trackId{
                            item.score = value![i].score
                            item.scoredate = value![i].scoredate
                        }
                    }
                }
            }
            
            next.item = item
            //nav.modalPresentationStyle = .automatic
            next.navigationItem.rightBarButtonItem = {
                let btn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.onPressDraftClose(_:)))
                return btn
            }()
            let nav = UINavigationController(rootViewController: next)
            self.present(nav, animated: true, completion: nil)
        })
        let playAction: UIAlertAction = UIAlertAction(title: "AppleMusicで聞く", style: UIAlertAction.Style.default, handler:{
            //AppleMusic
            (action: UIAlertAction!) -> Void in
            self.openAppMusic(url: item.trackViewUrl)
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        alert.addAction(playAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.MusicArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MusicCustomCell
        let item = self.MusicArray[indexPath.row]
        cell.setUpContents(item: item)

      return cell

    }
    
    func openAppMusic(url: String) {
        DispatchQueue.main.async {
            
            guard let url: URL = URL(string: url) else { return }
            
            // URLを開けるかをチェックする
            if !UIApplication.shared.canOpenURL(url) {
                return
            }
            // URLを開く
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    print("successful")
                }
            }
        }
    }
    @objc func onPressDraftClose(_ sender : Any){
        self.dismiss(animated: true, completion: nil)
    }
    
}
