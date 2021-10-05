//
//  TabBarController.swift
//  KaraokeScore
//
//  Created by Eiji Shiba on 2021/10/02.
//

import Foundation

import UIKit

class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // -----＊＊追記部分＊＊----- //
        // アイコンの色を変更できます！
        UITabBar.appearance().tintColor = UIColor.hex(string: "#fafafa", alpha: 1.0)
        // 背景色を変更できます！
        UITabBar.appearance().barTintColor = UIColor.hex(string: "#9896F1", alpha: 1.0)
        // -----＊＊追記部分＊＊----- //
    }

}
