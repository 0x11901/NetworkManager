//
//  ViewController.swift
//  NetworkManager
//
//  Created by 王靖凯 on 2017/11/16.
//  Copyright © 2017年 王靖凯. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBAction func requestButtonAction(_ sender: UIButton) {
        
        NetworkManager.shared.get(url: "https://raw.githubusercontent.com/0x11901/super-train/master/test.jsonss") {
                if let v = $0.value {
                    print(v)
                }
        }
        
    }
    
}

