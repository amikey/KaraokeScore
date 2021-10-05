//
//  ViewController.swift
//  KaraokeScore
//
//

import UIKit
import Alamofire
import SwiftyJSON
import Alertift
import EmptyStateKit
import StoreKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var largeurl : String?
    var medium_largeurl : String?
    var medium : String?
    var st_thumb150 : String?
    
    var MusicArray: [MusicInfoModel] = []
    
    var tableView: UITableView?
    fileprivate let refreshCtl = UIRefreshControl()
    
    let activityIndicatorView = UIActivityIndicatorView()
    
    var count = 1
    var count_s = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "登録スコア一覧"
        
        self.navigationItem.rightBarButtonItem = {
            let btn = UIBarButtonItem(title: "並び替え", style: .done, target: self, action: #selector(self.onPressSort(_:)))
            return btn
        }()
        self.navigationController!.navigationBar.barTintColor = UIColor.hex(string: "#9896F1", alpha: 1.0)
        self.navigationController!.navigationBar.tintColor = .white
        self.navigationController!.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white
        ]
        
        activityIndicatorView.center = self.view.center
        activityIndicatorView.style = UIActivityIndicatorView.Style.large
        activityIndicatorView.color = .gray
        activityIndicatorView.hidesWhenStopped = true
        self.navigationController?.view.addSubview(activityIndicatorView)
        self.activityIndicatorView.startAnimating()
        
        getArticles()
        
        self.tableView = {
            let tableView = UITableView(frame: self.view.bounds, style: .plain)
            tableView.autoresizingMask = [
              .flexibleWidth,
              .flexibleHeight
            ]
            tableView.refreshControl = refreshCtl
            refreshCtl.addTarget(self, action: #selector(ListViewController.refresh(sender:)), for: .valueChanged)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.register(MusicListCustomCell.self, forCellReuseIdentifier: "Cell")
            self.view.addSubview(tableView)

            return tableView

          }()
        alertreview()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getArticles()
        var format = EmptyStateFormat()
        format.imageSize.width = UIScreen.main.bounds.size.width * 0.9
        format.imageSize.height = UIScreen.main.bounds.size.width * 1.08
        view.emptyState.format = format
        if self.MusicArray.count == 0 {
            self.view.emptyState.show(State.empty)
        }
        else {
            self.view.emptyState.hide()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getArticles()
        var format = EmptyStateFormat()
        format.imageSize.width = UIScreen.main.bounds.size.width * 0.9
        format.imageSize.height = UIScreen.main.bounds.size.width * 1.08
        view.emptyState.format = format
        if self.MusicArray.count == 0 {
            self.view.emptyState.show(State.empty)
        }
        else {
            self.view.emptyState.hide()
        }
    }

    func getArticles() {
        
        if let data = UserDefaults.standard.value(forKey:"musicinfokey") as? Data {
            let value = try? PropertyListDecoder().decode(Array<MusicInfoModel>.self, from: data)
            self.MusicArray = []
            self.MusicArray.append(contentsOf: value ?? [])
            self.tableView?.reloadData()
        } else {
            print("失敗")
        }

        self.activityIndicatorView.stopAnimating()
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        getArticles()
        self.refreshCtl.endRefreshing()
    }
    @objc func onPressSort(_ sender : Any){
        let alert: UIAlertController = UIAlertController(title: "確認", message: "並び替える基準をタップしてください", preferredStyle:  UIAlertController.Style.actionSheet)
        let highscoreAction: UIAlertAction = UIAlertAction(title: "スコアが高い順", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.MusicArray.sort{
                if $0.score == $1.score {
                    return $0.trackName ?? "" > $1.trackName ?? ""
                }
                return $0.score ?? 0 > $1.score ?? 0
            }
            self.tableView?.reloadData()
        })
        let lowscoreAction: UIAlertAction = UIAlertAction(title: "スコアが低い順", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.MusicArray.sort{
                if $0.score == $1.score {
                    return $0.trackName ?? "" > $1.trackName ?? ""
                }
                return $0.score ?? 0 < $1.score ?? 0
            }
            self.tableView?.reloadData()
        })
        let aiueoAction: UIAlertAction = UIAlertAction(title: "あいうえお順", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.MusicArray.sort{
                if $0.trackName == $1.trackName {
                    return $0.score ?? 0 > $1.score ?? 0
                }
                return $0.trackName ?? "" < $1.trackName ?? ""
            }
            self.tableView?.reloadData()
        })
        let newAction: UIAlertAction = UIAlertAction(title: "スコア記録が新しい順", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.MusicArray.sort{
                if $0.scoredate == $1.scoredate {
                    return $0.trackName ?? "" > $1.trackName ?? ""
                }
                return $0.scoredate ?? Date() > $1.scoredate ?? Date()
            }
            self.tableView?.reloadData()
        })
        let oldAction: UIAlertAction = UIAlertAction(title: "スコア記録が古い順", style: UIAlertAction.Style.default, handler:{
            (action: UIAlertAction!) -> Void in
            self.MusicArray.sort{
                if $0.scoredate == $1.scoredate {
                    return $0.trackName ?? "" > $1.trackName ?? ""
                }
                return $0.scoredate ?? Date() < $1.scoredate ?? Date()
            }
            self.tableView?.reloadData()
        })
        // キャンセルボタン
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:{
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        
        alert.addAction(cancelAction)
        alert.addAction(highscoreAction)
        alert.addAction(lowscoreAction)
        alert.addAction(aiueoAction)
        alert.addAction(newAction)
        alert.addAction(oldAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        var item = self.MusicArray[indexPath.row]
        Alertift.alert(title: "確認", message: "「\(item.trackName)」をどうしますか？")
            .action(.default("編集する")) { [unowned self] in
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
                next.navigationItem.rightBarButtonItem = {
                    let btn = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.onPressDraftClose(_:)))
                    return btn
                }()
                let nav = UINavigationController(rootViewController: next)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
            .action(.destructive("削除する")) { [unowned self] in
                self.activityIndicatorView.startAnimating()
                
                self.MusicArray.remove(at: indexPath.row)
                
                UserDefaults.standard.set(try? PropertyListEncoder().encode(self.MusicArray), forKey:"musicinfokey")
                UserDefaults.standard.synchronize()

                getArticles()
                self.activityIndicatorView.stopAnimating()
                
                Alertift.alert(title: "完了", message: "データの削除が完了しました。")
                    .action(.default("OK")) { [unowned self] in
                        if self.MusicArray.count == 0 {
                            print("empty")
                            self.view.emptyState.show(State.empty)
                        }
                        else {
                            print("noempty")
                            self.view.emptyState.hide()
                        }
                        
                    }.show(on: self)
                
            }
            .action(.cancel("キャンセル"))
            .show(on: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
      return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.MusicArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MusicListCustomCell
        let item = self.MusicArray[indexPath.row]
        cell.setUpContents(item: item)

      return cell

    }
    @objc func onPressDraftClose(_ sender : Any){
        self.dismiss(animated: true, completion: nil)
    }
    func alertreview(){
        let key = "startUpCount"
        
        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: key) + 1, forKey: key)
        
        UserDefaults.standard.synchronize()
        
        if #available(iOS 10.3, *){
            
            //起動回数数が3回or10回or80回ごとなら
            UserDefaults.standard.synchronize()
            
            let key = "startUpCount"
            
            let count = UserDefaults.standard.integer(forKey: key)//起動回数
            print("count=\(count)")
            if(count == 3 || count == 10 || count % 80 == 0){
                
                SKStoreReviewController.requestReview()
            }
            
        }
    }
}
