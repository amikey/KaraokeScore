//
//  RecordViewController.swift
//  KaraokeScore
//
//  Created by Eiji Shiba on 2021/10/01.
//

import Foundation
import UIKit
import Eureka
import Alertift

class RecordViewController: FormViewController {
    
    var item: MusicInfoModel?
    
    override func viewDidLoad() {
        self.title = "スコア記録画面"
        
        super.viewDidLoad()
        form
            +++ Section("曲情報")
            <<< LabelRow("曲名"){ row in
                row.title = "曲名"
                row.value = self.item?.trackName
            }
            <<< LabelRow("歌手名"){ row in
                row.title = "歌手名"
                row.value = self.item?.artistName
            }
            <<< LabelRow("アルバム名"){ row in
                row.title = "アルバム名"
                row.value = self.item?.collectionName
            }
            
            +++ Section("スコア情報")
            <<< IntRow("スコア"){
                $0.title = "スコア"
                $0.placeholder = "80"
                if self.item?.score != 0 {
                    $0.value = self.item?.score
                }
            }.onChange {
                self.item?.score = $0.value ?? 0
                
                if $0.value ?? 0 > 100 {
                    $0.value = 100
                }
            }
            <<< DateRow("スコア更新日"){
                $0.title = "日付を選択"
                $0.value = self.item?.scoredate
            }.onChange {
                self.item?.scoredate = $0.value ?? Date()
            }
            
            +++ Section("")
            <<< ButtonRow("Button1") {row in
                row.title = "スコアを登録する"
                row.onCellSelection{[unowned self] ButtonCellOf, row in
                    if self.item?.score == nil || self.item?.scoredate == nil || self.item?.score ?? 0 < 0 || self.item?.score ?? 0 > 100 || self.item?.score ?? 0 == 0{
                        Alertift.alert(title: "警告", message: "正しい情報を入力してください")
                            .action(.default("OK")) { [unowned self] in
                                
                            }.show(on: self)
                    }
                    else{
                        Alertift.alert(title: "確認", message: "スコア記録を登録しますか？")
                            .action(.default("OK")) { [unowned self] in
                                let activityIndicatorView = UIActivityIndicatorView()
                                activityIndicatorView.center = self.view.center
                                activityIndicatorView.style = UIActivityIndicatorView.Style.large
                                activityIndicatorView.color = .gray
                                self.view.addSubview(activityIndicatorView)
                                activityIndicatorView.startAnimating()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    
                                    //現在のローカルを取得
                                    if let data = UserDefaults.standard.value(forKey:"musicinfokey") as? Data {
                                        var value = try? PropertyListDecoder().decode(Array<MusicInfoModel>.self, from: data)
                                        var flag = false
                                        //ローカルと新規読み込みが重複していないか確認
                                        if value != nil {
                                            for i in 0..<value!.count{
                                                if value![i].trackId == self.item?.trackId{
                                                    value![i].score = self.item!.score
                                                    value![i].scoredate = self.item!.scoredate
                                                    flag = true
                                                }
                                            }
                                        }
                                        //重複していない場合に追加処理
                                        if flag == false{
                                            value?.append(contentsOf: [self.item!])
                                        }
                                        
                                        UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey:"musicinfokey")
                                        UserDefaults.standard.synchronize()

                                        activityIndicatorView.stopAnimating()
                                        Alertift.alert(title: "完了", message: "スコアの記録が完了しました")
                                            .action(.default("OK")) { [unowned self] in
                                                self.dismiss(animated: true, completion: nil)
                                            }.show(on: self)
                                        
                                        
                                    } else {
                                        UserDefaults.standard.set(try? PropertyListEncoder().encode([self.item!]), forKey:"musicinfokey")
                                        UserDefaults.standard.synchronize()
                                        Alertift.alert(title: "完了", message: "スコアの記録が完了しました")
                                            .action(.default("OK")) { [unowned self] in
                                                self.dismiss(animated: true, completion: nil)
                                            }.show(on: self)
                                    }
                                    
                                }
                            }
                            .action(.cancel("キャンセル")).show(on: self)
                    }
                }
            }
    }
    
}
