//
//  SplitViewController.swift
//  MemoKing
//
//  Created by Nu-Ri Lee on 2017. 5. 1..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class SplitViewController : UISplitViewController{
    
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet var addItemView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        print("split뷰 실행");
        
        var bg_size:CGFloat;
        if self.view.frame.width <= self.view.frame.height{
            bg_size = self.view.frame.height + 100;
        }else{
            bg_size = self.view.frame.width + 100;
        }
        
        self.view.addSubview(addItemView);
        addItemView.frame = CGRect(origin: self.view.center, size: CGSize(width: bg_size, height: bg_size))
        addItemView.center = self.view.center;
        
        blurView.effect = nil;
        
        addItemView.isUserInteractionEnabled = false;
        blurView.isUserInteractionEnabled = false;
        
        //방송국 옵저버 등록
        let name = Notification.Name("blur_show");
        NotificationCenter.default.addObserver(self, selector: #selector(blur_show), name: name, object: nil)
        
        
        //방송국 옵저버 등록
        let name2 = Notification.Name("blur_hide");
        NotificationCenter.default.addObserver(self, selector: #selector(blur_hide), name: name2, object: nil)
        
        
        //방송국 옵저버 등록
        let name3 = Notification.Name("lockScreen");
        NotificationCenter.default.addObserver(self, selector: #selector(lockScreen), name: name3, object: nil)
        
        
        
        //UserDefaults.standard.set("", forKey: "passCode");
        
        
        
        
        
        
    }
    
    @objc func lockScreen(){
        let lock = UserDefaults.standard.object(forKey: "password") as? Bool ?? false;
        if lock {
            UserDefaults.standard.set(false, forKey: "password");
            
            
            print("비밀번호창 이동");
            self.performSegue(withIdentifier: "toPassword", sender: self);
            
            
            
        }
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        

    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPassword" {
            let secondVC = segue.destination as! PassCodeViewController
            
            secondVC.param = 1;
            
        }
    }
    
    
    
    @objc func blur_show(){
        //커스텀 클래스 불러오기
        let data = UserDefaults.standard.object(forKey: "BV") as? Data ?? Data();
        let BV = NSKeyedUnarchiver.unarchiveObject(with: data) as? Blur ?? Blur();
        
        
        BV.showBlur(blurView: blurView)
        
        //blur 전역변수 저장
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: BV)
        UserDefaults.standard.set(encodedData, forKey: "BV")

    }
    
    @objc func blur_hide(){
        //커스텀 클래스 불러오기
        let data = UserDefaults.standard.object(forKey: "BV") as? Data ?? Data();
        let BV = NSKeyedUnarchiver.unarchiveObject(with: data) as? Blur ?? Blur();
        
        BV.hideBlur(blurView: blurView)
        
        
        //blur 전역변수 저장
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: BV)
        UserDefaults.standard.set(encodedData, forKey: "BV")
    }
}


class Blur : NSObject, NSCoding{
    var blur_bool : Bool = false;
    
    override init(){
        
    }
    
    required init(coder aDecoder: NSCoder) {
        self.blur_bool = aDecoder.decodeBool(forKey: "blur_bool")
        
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.blur_bool, forKey: "blur_bool")
    }
    
    
    public func showBlur(blurView : UIVisualEffectView){
        //        UIView.animate(withDuration: 0.3) { blurView.effect = UIBlurEffect(style: .light) }
        //        blurView.pauseAnimation(delay: 0.1)
        blurView.isHidden = false;
        blurView.effect = UIBlurEffect(style: .light)
        blur_bool = true;
        //print("show");
    }
    
    public func hideBlur(blurView : UIVisualEffectView){
        blurView.resumeAnimation()
        blurView.effect = nil
        blurView.isHidden = true;
        //UIView.animate(withDuration: 0.3) { self.blurView.effect = nil }
        blur_bool = false;
        //print("hide");
    }
}


