//
//  ViewController.swift
//  PassCode
//
//  Created by Nu-Ri Lee on 2017. 5. 2..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit
import LocalAuthentication
import AVFoundation
import AudioToolbox

class PassCodeViewController: UIViewController {

    @IBOutlet weak var dotsView: UIView!
    
    @IBOutlet var dots: [Dot]!
    
    @IBOutlet weak var subTitleLabel: UILabel!
    
    @IBOutlet weak var btn_Cancel: UIButton!
    
    var passCodeLock : PassCodeLock!
    
    
    //param값이 0이면 비밀번호 셋팅, 1이면 비밀번호 풀기
    var param : Int?
    
    @IBAction func btn_Cancel(_ sender: Any) {
        let noti = Notification.init(name : Notification.Name(rawValue: "initSwitch"));
        NotificationCenter.default.post(noti);
        self.presentingViewController?.dismiss(animated: true)
    }
        
    @IBAction func passCodeButtonTap(_ sender: PassCodeButton) {
        
        
        if param! == 0{
            //비밀번호 셋팅
            
            //리턴값 0일때는 진행중, 1일때는 1차성공, 2일때는 2차 안맞음, 3일때는 성공
            switch (passCodeLock.setPassword(sender.passcodeSign))
            {
            case 0 :
                //print("진행중");
                break;
            case 1 :
                //print("실패");
                subTitleLabel.text = NSLocalizedString("oneMorePassword", comment: "oneMorePassword");
                break;
            case 2 :
                //print("비밀번호 안맞음");
                subTitleLabel.text = NSLocalizedString("passwordNotMach", comment: "passwordNotMach");
                break;
            case 3 :
                //print("성공");
                UserDefaults.standard.set(true, forKey: "password2")
                UserDefaults.standard.set(true, forKey: "password");
                let noti = Notification.init(name : Notification.Name(rawValue: "initSwitch"));
                NotificationCenter.default.post(noti);
                self.presentingViewController?.dismiss(animated: true)
                break;
            default :
                print("error");
            }
            
        }else{
            //비밀번호 풀기
            
            //리턴값 0일때는 진행중, 1일때는 실패, 2일때는 성공
            switch (passCodeLock.addPassword(sender.passcodeSign))
            {
            case 0 :
                //print("진행중");
                break;
            case 1 :
                //print("실패");
                subTitleLabel.text = NSLocalizedString("passwordFailed", comment: "passwordFailed");
                break;
            case 2 :
                //print("성공");
                if param! == 2{ //비번 제거
                    UserDefaults.standard.set("", forKey: "passCode");
                    UserDefaults.standard.set(false, forKey: "password");
                }
                if param! == 1{ //비번 풀기
                    let blur = UserDefaults.standard.object(forKey: "blur") as? Bool ?? false;
                    if blur {
                        let noti = Notification.init(name : Notification.Name(rawValue: "blur_hide"));
                        NotificationCenter.default.post(noti);
                    }else{
                        
                    }
                }
                UserDefaults.standard.set(true, forKey: "password2")
                UserDefaults.standard.set(false, forKey: "password");
                self.presentingViewController?.dismiss(animated: true)
                
                

                break;
            default :
                print("error");
            }
        }
        
        
        
    }
    
    @IBAction func deleteButtonTap(_ sender: Any) {
        passCodeLock.removePassword();
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        view.superview?.bringSubview(toFront: view)
    }
    
    
    @objc func passCodeViewDismiss(){
        if passCodeDismiss{
            if param! == 2{ //비밀번호 제거일때
                self.presentingViewController?.dismiss(animated: true)
            }
        }
    }
    
    var passCodeDismiss : Bool = false;
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        passCodeDismiss = true;
        
        
        //우체국 등록
        let name1 = Notification.Name("passCodeViewDismiss");
        NotificationCenter.default.addObserver(self, selector: #selector(passCodeViewDismiss), name: name1, object: nil)
        
        //param = 0;
        
//        if param == nil{
//            print("nil");
//        }else{
//            print(param!)
//        }
        
        
        let passCode = UserDefaults.standard.object(forKey: "passCode") as? String ?? String();
        
        passCodeLock = PassCodeLock(dots: dots, dotsView : dotsView)
        
        if param! == 0{
            //setting
            subTitleLabel.text = NSLocalizedString("setPassword", comment: "setPassword");
        }else if param! == 1{
            
            UserDefaults.standard.set(false, forKey: "password2")
            
            //enter
            btn_Cancel.isEnabled = false;
            btn_Cancel.isHidden = true;
            passCodeLock.password = passCode;
            subTitleLabel.text = NSLocalizedString("enterPassword", comment: "enterPassword");
            
            let touchID = UserDefaults.standard.object(forKey: "touchID") as? Bool ?? false;
            
            
            if touchID {
                
                print("페이스아디 시작");
                
                //Touch Id
                authenticateUser();
                
                
            }
            
        }else if param! == 2{
            //enter
            passCodeLock.password = passCode;
            subTitleLabel.text = NSLocalizedString("enterPassword", comment: "enterPassword");
            
            let touchID = UserDefaults.standard.object(forKey: "touchID") as? Bool ?? false;
            if touchID {
                //Touch Id
                //authenticateUser();
            }
        }
        
        
        
        
        
    }
    
    func authenticateUser(){
        
        
        
        
        
 
        
        //touch id 기본소스 생체인증
        
        let context = LAContext();
        var error:NSError?
        //let reasonString = "Please do fingerprint recognition."
        let reasonString = NSLocalizedString("enterTouchId", comment: "enterTouchId");
      
        
        if context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
        {
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { (success, error) in
                
                if success
                {
                    
                    //print("성공");
                    
 
                    if self.param! == 2{ //비번 제거
                        UserDefaults.standard.set("", forKey: "passCode");
                    }
                    if self.param! == 1{ //비번 풀기
                        let blur = UserDefaults.standard.object(forKey: "blur") as? Bool ?? false;
                        if blur {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                let noti = Notification.init(name : Notification.Name(rawValue: "blur_hide"));
                                NotificationCenter.default.post(noti);
                            }
                        }else{
                            
                        }
                    }
                    UserDefaults.standard.set(true, forKey: "password2")
                    UserDefaults.standard.set(false, forKey: "password");
                    
                    
                    //화면 싱크 맞추기
                    DispatchQueue.main.async {
                        self.presentingViewController?.dismiss(animated: true)
                    }
 
 
                    
                }else{
                    
                    switch (error!._code){
                    case LAError.systemCancel.rawValue:
                        print("cancelled by the system.");
                    case LAError.userCancel.rawValue:
                        print("canselled by the user.");
                    case LAError.userFallback.rawValue:
                        
                        print("User selected to enter password.");
                        OperationQueue.main.addOperation {
                            //self.showPasswordAlert();
                        }
                    default:
                        print("failed!");
                        
                        OperationQueue.main.addOperation {
                            //self.showPasswordAlert();
                        }                    }
                }
            }
            
        }else{
            print(error?.localizedDescription ?? "error")
            OperationQueue.main.addOperation {
                //self.showPasswordAlert();
            }
        }
 
 
    }
    
    //화면 회전 금지
    override var shouldAutorotate: Bool{
        if UIDevice.current.userInterfaceIdiom == .phone{
            return false;
        }else{
            return true;
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
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


//뷰에 흔들기 애니메이션 추가
extension UIView {
    func shake(duration: CFTimeInterval) {
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x");
        translation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        translation.values = [-16, 16, -16, 16, -12, 12, -6, 6, 0]
        
        //        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        //        rotation.values = [-5, 5, -5, 5, -3, 3, -2, 2, 0].map {
        //            ( degrees: Double) -> Double in
        //            let radians: Double = (.pi * degrees) / 180.0
        //            return radians
        //        }
        
        let shakeGroup: CAAnimationGroup = CAAnimationGroup()
        //shakeGroup.animations = [translation, rotation]
        shakeGroup.animations = [translation]
        shakeGroup.duration = duration
        self.layer.add(shakeGroup, forKey: "shakeIt")
    }
}

