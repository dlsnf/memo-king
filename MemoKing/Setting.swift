//
//  Write.swift
//  MemoKing
//
//  Created by Nu-Ri Lee on 2017. 4. 11..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class Setting : UIViewController{
    
    @IBAction func btn_back(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    //복사 붙여넣기 금지
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.paste(_:)) || action == #selector(UIResponderStandardEditActions.copy(_:)) {
            return false
        }
        
        return super.canPerformAction(action, withSender: sender)
    }
    
    @IBOutlet weak var toggle: UISwitch!
    
    
//    var pwdTextField : UITextField;
//    var pwdTextField2 : UITextField;
    
   
    @IBAction func passwordToggle(_ sender: Any) {
        if (sender as AnyObject).isOn{
            print("on");
            setPassword(nil)
        }else{
            print("off");
        }
    }
    
    var pwd1 = String();
    var pwd2 = String();
    
    func setPassword(_ message:String?){
        
        let alertController = UIAlertController(title: "Set password", message: message, preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "OK", style: .default) { (action) -> Void in
            
            if let textField = alertController.textFields?[0] as UITextField?
            {
                self.pwd1 = textField.text!;
            }
            
            if let textField = alertController.textFields?[1] as UITextField?
            {
                self.pwd2 = textField.text!;
            }
            
            
            //비밀번호 입력하지 않을때
            if self.pwd1.isEmpty{
                self.setPassword("비밀번호를 입력해 주세요.");
            }else if self.pwd2.isEmpty{
                self.setPassword("Repeat password");
            }else if self.pwd1 != self.pwd2 {
                self.setPassword("비밀번호가 동일하지 않습니다.");
            }else{
                self.pwd1 = "";
                self.pwd2 = "";
            }
            
        }
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            self.pwd1 = "";
            self.pwd2 = "";
            self.toggle.isOn = false;
            //print("Cancel button tapped")
        })
        
        
        alertController.addAction(defaultAction);
        alertController.addAction(cancelButton)
        
        alertController.addTextField { (textField) -> Void in
            textField.keyboardType = UIKeyboardType.numberPad;
            textField.text = self.pwd1;
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true;
        }
        
        alertController.addTextField { (textField2) -> Void in
            textField2.text = self.pwd2;
            textField2.placeholder = "Password"
            textField2.isSecureTextEntry = true;
        }
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //네비게이션바 뒤로가기 버튼 텍스트 지우기
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        
    }
    
    
}

