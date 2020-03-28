//
//  SettingViewController.swift
//  MemoKing
//
//  Created by Nu-Ri Lee on 2017. 5. 9..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit
import LocalAuthentication

class SettingViewController : UITableViewController, UIViewControllerTransitioningDelegate{
    
    let transition2 = CircularTransition();
    
    
    
    @IBOutlet weak var btn2: UIButton!
    
    @IBOutlet weak var setPassword: UISwitch!
    @IBOutlet weak var touchId: UISwitch!
    @IBOutlet weak var touchIdLabel: UILabel!
    @IBOutlet weak var touchIdSubLabel: UILabel!
    
    
    @IBOutlet weak var hideBackground: UISwitch!
    
    
    @IBAction func hideBackground(_ sender: Any) {
        
        if (sender as AnyObject).isOn{
            UserDefaults.standard.set(true, forKey: "blur");
        }else{
            UserDefaults.standard.set(false, forKey: "blur");
        }
        
        
    }
    
    
    @IBAction func setPasswordSwitch(_ sender: Any) {
        if (sender as AnyObject).isOn{
            
            let context = LAContext();
            var error:NSError?
            if !context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
            {
                //print("touch id 없음")
                //print(error?.localizedDescription ?? "error")
                touchIdSubLabel.isHidden = false;
                touchId.isOn = false;
                touchId.isEnabled = false;
                UserDefaults.standard.set(false, forKey: "touchID");
            }else{
                //print("touch id 있음")
                touchIdSubLabel.isHidden = true;
                touchId.setOn(true, animated: true);
                touchId.isEnabled = true;
                if #available(iOS 13.0, *) {
                    touchIdLabel.textColor = UIColor.label
                } else {
                    // Fallback on earlier versions
                    touchIdLabel.textColor = UIColor.black;
                };
                UserDefaults.standard.set(true, forKey: "touchID");
            }
            
        }else{
            
            touchIdSubLabel.isHidden = true;
            touchId.setOn(false, animated: true);
            touchId.isEnabled = false;
            touchIdLabel.textColor = UIColor.gray;
            
        }
        
        
        self.performSegue(withIdentifier: "toPassCode", sender: self);
    }
    
    @IBAction func touchIdSwitch(_ sender: Any) {
        if (sender as AnyObject).isOn{
            UserDefaults.standard.set(true, forKey: "touchID");
        }else{
            UserDefaults.standard.set(false, forKey: "touchID");
        }
    }
    
    
    @IBAction func dismissView(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition2.transitionMode = .present
        transition2.startingPoint = CGPoint(x: (btn2.superview?.convert(btn2.frame.origin, to: self.view))!.x + btn2.frame.width/2, y: (btn2.superview?.convert(btn2.frame.origin, to: self.view))!.y + (self.navigationController?.navigationBar.frame.size.height)! + btn2.frame.height/2 + 20)
        
        
        transition2.circleColor = btn2.backgroundColor!;
        return transition2
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition2.transitionMode = .dismiss
        transition2.startingPoint = CGPoint(x: (btn2.superview?.convert(btn2.frame.origin, to: self.view))!.x + btn2.frame.width/2, y: (btn2.superview?.convert(btn2.frame.origin, to: self.view))!.y + (self.navigationController?.navigationBar.frame.size.height)! + btn2.frame.height/2 + 20)
        
        
        transition2.circleColor = btn2.backgroundColor!;
        
        return transition2
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPassCode" {
            let secondVC = segue.destination as! PassCodeViewController
            secondVC.transitioningDelegate = self as UIViewControllerTransitioningDelegate
            secondVC.modalPresentationStyle = .custom
            
            let passCode = UserDefaults.standard.object(forKey: "passCode") as? String ?? String();
            if passCode.isEmpty{
                //비번 설정
                secondVC.param = 0;
            }
            else{
                //비번 풀기
                secondVC.param = 2;
            }
            
        }
    }
    
    
    @objc func initSwitch(){
        let passCode = UserDefaults.standard.object(forKey: "passCode") as? String ?? String();
        if passCode.isEmpty{
            setPassword.isOn = false;
        }
        else{
            setPassword.isOn = true;
        }
        
        if (setPassword as AnyObject).isOn{
            
            let context = LAContext();
            var error:NSError?
            if !context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)
            {
                //print("touch id 없음")
                //print(error?.localizedDescription ?? "error")
                touchIdSubLabel.isHidden = false;
                touchId.isOn = false;
                touchId.isEnabled = false;
                UserDefaults.standard.set(false, forKey: "touchID");
            }else{
                //print("touch id 있음")
                touchIdSubLabel.isHidden = true;
                touchId.isEnabled = true;
                if #available(iOS 13.0, *) {
                    touchIdLabel.textColor = UIColor.label
                } else {
                    // Fallback on earlier versions
                    touchIdLabel.textColor = UIColor.black;
                };
            }
            
        }else{
            
            touchIdSubLabel.isHidden = true;
            touchId.setOn(false, animated: true);
            touchId.isEnabled = false;
            touchIdLabel.textColor = UIColor.gray;
            UserDefaults.standard.set(false, forKey: "touchID");
        }
        
        
        
        let touchID = UserDefaults.standard.object(forKey: "touchID") as? Bool ?? false;
        if touchID {
            touchId.isOn = true;
        }else{
            touchId.isOn = false;
        }
        
        let blur = UserDefaults.standard.object(forKey: "blur") as? Bool ?? false;
        if blur {
            hideBackground.isOn = true;
        }else{
            hideBackground.isOn = false;
        }
        
        
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initSwitch();
    }
    
    @objc func settingViewDismiss(){
        if settingDismiss{
            self.presentingViewController?.dismiss(animated: true)
        }
    }
    
    
    var settingDismiss : Bool = false;
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        
        settingDismiss = true;
        
        
        
        
        
        
        
        
        
        let name = Notification.Name("initSwitch");
        NotificationCenter.default.addObserver(self, selector: #selector(SettingViewController.initSwitch), name: name, object: nil)
        
        let name2 = Notification.Name("settingViewDismiss");
        NotificationCenter.default.addObserver(self, selector: #selector(settingViewDismiss), name: name2, object: nil)
        
        
        
        
        btn2.layer.cornerRadius = btn2.frame.size.width / 2
        btn2.isEnabled = false;
        btn2.isHidden = true;
        
        
    }
    
        
    
    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        
//        var headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 36)) //X is the value of height of your header
//        var label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 36))
//        
//        
//        switch (section){
//        case 0 :
//            if UIDevice.current.userInterfaceIdiom == .pad{
//                label.text = "        PASSWORD"
//                label.font = UIFont.boldSystemFont(ofSize: 14.0)
//            }else{
//                
//                label.text = "    PASSWORD"
//                label.font = UIFont.boldSystemFont(ofSize: 12.0)
//            }
//            break;
//        default :
//            headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.size.width, height: 44)) //X is the value of height of your header
//            label = UILabel(frame: CGRect(x: 0, y: 20, width: self.tableView.frame.size.width, height: 20))
//            break;
//        }
//        
//        label.textAlignment = NSTextAlignment.left;
//        label.textColor = UIColor.gray
//        headerView.addSubview(label)
//        
//        return headerView;
//    }
//    
//    //static 섹션 Header 높이설정
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 36;
//        }else{
//            return 44;
//        }
//    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
