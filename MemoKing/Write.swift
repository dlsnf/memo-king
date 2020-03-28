//
//  Write.swift
//  MemoKing
//
//  Created by Nu-Ri Lee on 2017. 4. 11..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

class Write : UIViewController, UITextViewDelegate, UIActionSheetDelegate, UISplitViewControllerDelegate{
    
// MARK: - Variable
    
    //넘버
    var memoNumber : Int = Int();
   
    //메모 순서
    var memoSequence : [Int] = [Int]();
    
    //메모 마지막 번호
    var memoLastNumber : Int = Int();
    
    //메모데이타
    var memoData : [memoValue] = [memoValue]();
    
    @IBAction func btn_toolBar(_ sender: Any) {
        save();
//        writeTextView.resignFirstResponder();
//        let noti = Notification.init(name : Notification.Name.UIKeyboardWillHide);
//        NotificationCenter.default.post(noti);
    }
    
    @IBOutlet weak var btn_delete: UIBarButtonItem!
    @IBOutlet var toolBar: UIView!
    
    @IBOutlet weak var btn_save: UIBarButtonItem!
    
    @IBOutlet weak var writeTextView: UITextView!
    
    
// Variable_End
    
    @objc func keyBoardDisabled(){
        writeTextView.resignFirstResponder();
    }
    
    @objc func detail_init(){
        self.navigationItem.title = NSLocalizedString("new", comment: "new");
        UserDefaults.standard.set(-1, forKey: "memoNumber");
        self.writeTextView.text = "";
        self.btn_delete.isEnabled = false;
        self.viewDidLoad();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true);
        btn_save.isEnabled = false;
        
        
        
    }
    
    var start : CGFloat = 0.0;
    var change : CGFloat = 0.0;
    var end : CGFloat = 0.0;
    @objc func dragging(_ sender : UIPanGestureRecognizer){
        let point = sender.location(in: view);
        //드래그된 뷰 객체
        //let draggedView = sender.view!;
        //draggedView.center = point;
        
        
        if sender.state == UIGestureRecognizerState.began {
            start = point.y;
            print("시작 - \(start)")
            //add something you want to happen when the Label Panning has started
        }
        
        if sender.state == UIGestureRecognizerState.ended {
            end = point.y;
            
               print("끝 - \(end)")
            
            //add something you want to happen when the Label Panning has ended
            
        }
        
        
        if sender.state == UIGestureRecognizerState.changed {
            change = point.y;
            if (change >= start && change <= UIScreen.main.bounds.height){
                print("바뀔때? - \(change)")
            }
            //add something you want to happen when the Label Panning has been change ( during the moving/panning )

        }
            
        else {
            //print("모징");
            // or something when its not moving
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        //디바이스 체크
        if UIDevice.current.userInterfaceIdiom == .phone{
            //print("phone");
            
            //툴바 넣기
            writeTextView.inputAccessoryView = toolBar;
            
            
            //드래그 제스처 생성 및 적용
            let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragging));
            toolBar.addGestureRecognizer(gestureRecognizer);
            
        }else if UIDevice.current.userInterfaceIdiom == .pad{
            //print("pad");
        }
        
        
        
        
        //detail_init 옵저버
        let name = Notification.Name("detail_init");
        NotificationCenter.default.addObserver(self, selector: #selector(detail_init), name: name, object: nil)
        
        
        let name2 = Notification.Name("keyBoardDisabled");
        NotificationCenter.default.addObserver(self, selector: #selector(keyBoardDisabled), name: name2, object: nil)
        
        let name3 = Notification.Name("save");
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: name3, object: nil)
        
        //split에서 확장모드
        navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem;
        navigationItem.leftItemsSupplementBackButton = true;
        
        //split뷰에서 아이폰에서 마스터 먼저 보이기
        self.splitViewController?.delegate = self;
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible;
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        //배경 그라디언트 추가
        background_gradation_update();
        
        
        //순서 불러오기
        memoSequence = UserDefaults.standard.object(forKey: "memoSequence") as? [Int] ?? [Int]();
        
        memoNumber = UserDefaults.standard.object(forKey: "memoNumber") as? Int ?? -1;
        
        
        
        //커스텀 클래스 불러오기
        let data = UserDefaults.standard.object(forKey: "memoData") as? Data ?? Data();
        memoData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [memoValue] ?? [memoValue]();

       
        
        
        if memoNumber == -1{
            
            writeTextView.text = "";
            writeTextView.becomeFirstResponder()
            
        }else{
            
            //WHERE 문으로 인덱스값 찾기
            if let i = self.memoData.index(where: { $0.memoNumber == memoNumber }) {
                //print("메모 index : \(i)")
                writeTextView.text = memoData[i].text;

                
            }else{
                print("메모에서 찾을 수 없습니다.");
            }
            
            
        }
        
        
    }
    
    
    //다크모드 자동 체크
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if #available(iOS 12.0, *) {
            let userInterfaceStyle = traitCollection.userInterfaceStyle
            
            if userInterfaceStyle == .dark
            {
                //print("다크이이이잉");
            }else{
                //print("다크아님");
            }
            background_gradation_update();
        } else {
            // Fallback on earlier versions
        } // Either .unspecified, .light, or .dark
        // Update your user interface based on the appearance
        
        
    }
    
    
    
    func background_gradation_update()
    {
        
        var background : CALayer ;
        
        //다크모드 체크
        if #available(iOS 12.0, *) { //12버전 이상일때
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                //배경 그라디언트 추가
                background = CAGradientLayer().turquoiseColorDark();
            } else {
                // User Interface is Light
                //배경 그라디언트 추가
                background = CAGradientLayer().turquoiseColor()
            }
        } else {
            // Fallback on earlier versions
            //배경 그라디언트 추가
            background = CAGradientLayer().turquoiseColor()
        }
        
        
        //큰곳으로 기준잡기
        var bg_size = CGFloat();
        if self.view.frame.width <= self.view.frame.height{
            bg_size = self.view.frame.height;
        }else{
            bg_size = self.view.frame.width;
        }
        background.frame = CGRect(x: 0, y: 0, width: bg_size, height: bg_size)
        
        background.name = "gradation_back";
        
        for layer in self.view.layer.sublayers! {
            if layer.name == "gradation_back" {
                 layer.removeFromSuperlayer()
            }
        }
        self.view.layer.insertSublayer(background, at: 0)
    }
    
    
    
    
 //MARK: - Action
    @IBAction func saveClick(_ sender: Any) {
        save();
    }
    
        
    @objc func save(){
        if !writeTextView.text.isEmpty{
            
            memoNumber = UserDefaults.standard.object(forKey: "memoNumber") as? Int ?? -1;
        
            //시간 설정
            let date:Date = Date();
            
            
            if memoNumber == -1{
                
                memoLastNumber = UserDefaults.standard.object(forKey: "memoLastNumber") as? Int ?? Int();
               
                
                let mv : memoValue = memoValue(memoNumber : memoLastNumber, text: writeTextView.text, date: date)
                memoData.append(mv);
                
                
                
                //커스텀 클래스 저장
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: memoData)
                UserDefaults.standard.set(encodedData, forKey: "memoData")
                
                
                //커스텀 클래스 불러오기
//                let data = UserDefaults.standard.object(forKey: "memoData") as? Data ?? Data();
//                memoData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [memoValue] ?? [memoValue]();
//                
//                print(memoData[0].memoNumber);
                
                
                
                //메모넘버 저장
                UserDefaults.standard.set(memoLastNumber, forKey: "memoNumber");
                
                //순서 저장
                memoSequence.append(memoLastNumber);
                UserDefaults.standard.set(memoSequence, forKey: "memoSequence")
                
                //메모 라스트 넘버 증가 후 저장
                memoLastNumber += 1;
                UserDefaults.standard.set(memoLastNumber, forKey: "memoLastNumber")
                
             
                self.btn_delete.isEnabled = true;
                self.navigationItem.title = NSLocalizedString("memo", comment: "memo");
             
            }else{// 수정하기
                //WHERE 문으로 인덱스값 찾기
                if let i = self.memoData.index(where: { $0.memoNumber == memoNumber }) {
                    //print("메모 index : \(i)")                   
                    
                    memoData[i].text = writeTextView.text;
                    memoData[i].date = date;
                    
                    
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: memoData)
                    UserDefaults.standard.set(encodedData, forKey: "memoData")
                    
                    
                }else{
                    print("메모에서 찾을 수 없습니다.");
                }
            }
            
            
        }
        
        
        
        writeTextView.resignFirstResponder();
        let noti = Notification.init(name : Notification.Name.UIKeyboardWillHide);
        NotificationCenter.default.post(noti);
        
        btn_save.isEnabled = false;
        
        //마스터 테이블뷰 리로드
        reloadMasterTableView();
        
        
        //네비게이션 뒤로가기
        //self.navigationController?.popViewController(animated: true)
        
        
    }
    
    func reloadMasterTableView(){
        let noti = Notification.init(name : Notification.Name(rawValue: "table_reload"));
        NotificationCenter.default.post(noti);
        
    }
    
    
    @IBAction func text_delete(_ sender: Any) {
        
        if !writeTextView.text.isEmpty {
            
            let alertController = UIAlertController();
            
            let  deleteButton = UIAlertAction(title: NSLocalizedString("delete", comment: "delete"), style: .destructive, handler: { (action) -> Void in
                print("Delete button tapped")
                
                
                self.memoNumber = UserDefaults.standard.object(forKey: "memoNumber") as? Int ?? Int();
                
                //커스텀 클래스 불러오기
                let data = UserDefaults.standard.object(forKey: "memoData") as? Data ?? Data();
                
                
                self.memoData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [memoValue] ?? [memoValue]();
                

                
                //WHERE 문으로 인덱스값 찾기
                if let i = self.memoData.index(where: { $0.memoNumber == self.memoNumber }) {
                    print("메모 index : \(i)")
                    self.memoData.remove(at: i);
                    
                    //메모데이타 저장
                    let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.memoData)
                    UserDefaults.standard.set(encodedData, forKey: "memoData")
                    
                    //메모장 삭제되었으면 순서에서도 삭제
                    if let i = self.memoSequence.index(of: self.memoNumber ) {
                        print("순서 index : \(i)")
                        self.memoSequence.remove(at: i);
                        
                        //순서저장
                        UserDefaults.standard.set(self.memoSequence, forKey: "memoSequence")
                        
                        self.detail_init();
                        
                        self.reloadMasterTableView()
                        
                    }else{
                        print("순서에서 찾을 수 없습니다.");
                    }
                    
                    
                }else{
                    print("메모에서 찾을 수 없습니다.");
                }
                
                
                
                
                
                //네비게이션 뒤로가기
                //self.navigationController?.popViewController(animated: true)
                
                
                //ipad 일때
                if alertController.popoverPresentationController != nil {
                    //print("RB");
                }
                
                
            })
            
            let cancelButton = UIAlertAction(title: NSLocalizedString("cancel", comment: "cancel"), style: .cancel, handler: { (action) -> Void in
                print("Cancel button tapped")
            })
            alertController.addAction(deleteButton)
            alertController.addAction(cancelButton)
            
            //ipad 일때 위치 잡아주기
            if let popoverPresentationController = alertController.popoverPresentationController {
                
                
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.width / 2.0 , y: self.view.bounds.height - 48 , width: 1, height: 1)
            }
            
            self.present(alertController, animated: true, completion: nil)

            
            
            
            
            

        }
    }
 //Action_End
    
    
//MARK: - DELEGATE
    var key_check:Bool = false;
    @objc func keyboardWillShow(notification: NSNotification) {
        if key_check == false{
            adjustingHeight(true, notification: notification as Notification)
        }
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if key_check == true{
            adjustingHeight(false, notification: notification as Notification)
        }
    }
    
    func adjustingHeight(_ show:Bool, notification:Notification) {
        
        
        var keyboardHeight:CGFloat = 0;
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            keyboardHeight = keyboardSize.height;
            //print(keyboardHeight);
        }
        
        let changeInHeight = (keyboardHeight - 40);
        
        
        if show{
            writeTextView.contentInset.bottom += changeInHeight
            
            writeTextView.scrollIndicatorInsets.bottom += changeInHeight
            key_check = true;
        }else{
            writeTextView.contentInset.bottom = 0
            
            writeTextView.scrollIndicatorInsets.bottom = 0
            key_check = false;
        }
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        if writeTextView.text.isEmpty{
            btn_save.isEnabled = false;
        }else{
            btn_save.isEnabled = true;
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//DELEGATE_End
    
}

