//
//  SettingNavigationController.swift
//  MemoKing
//
//  Created by Nu-Ri Lee on 2017. 5. 12..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class SettingNavigationController : UINavigationController{
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        
        if UIDevice.current.userInterfaceIdiom == .phone{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                //화면 강제회전
                let value = UIInterfaceOrientation.portrait.rawValue
                UIDevice.current.setValue(value, forKey: "orientation")
            }
        }
        
    }
    
    //화면 회전 고정
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        if UIDevice.current.userInterfaceIdiom == .phone{
            return [UIInterfaceOrientationMask.portrait]
        }else{
            return [UIInterfaceOrientationMask.all]
        }
    }

    
    
}
