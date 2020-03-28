//
//  ViewController.swift
//  MemoKing
//
//  Created by Nu-Ri Lee on 2017. 4. 11..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit
import GoogleMobileAds



class Main : UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating, UISearchBarDelegate, UISplitViewControllerDelegate, UIViewControllerTransitioningDelegate, GADBannerViewDelegate{
        
    
    @IBOutlet weak var barBtn: UIBarButtonItem!
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var btn: UIButton!
    
    
    
    
    
    let transition = CircularTransition();
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true;
    }
    
    var btn_trasition_point:CGPoint = CGPoint();
    var memoNumber : Int = Int();
    
    //메모 마지막 번호
    var memoLastNumber : Int = Int();
    
    //메모 순서
    var memoSequence : [Int] = [Int]();
    
    var memoData : [memoValue] = [memoValue]();
    
    var filteredArray : [memoValue] = [memoValue]();
    var searchActive : Bool = false;
    
    var resultSearchController = UISearchController()
    

    
    @IBOutlet weak var tableView: UITableView!
    
    //private let refreshControl = UIRefreshControl()
    
    @objc func table_reload(){
        tableView.reloadData();
        add_bool = false;
    }
  
    //테이블 애니메이션
    func animateTable(){
        tableView.reloadData()
        let cells = tableView.visibleCells;
        let tableViewHeight = tableView.bounds.size.height/5;
        
        for cell in cells{
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        
        var delayCounter = 0;
        for cell in cells{
            UIView.animate(withDuration: 1,delay: Double(delayCounter) * 0.03,usingSpringWithDamping:0.8, initialSpringVelocity:0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity;
            }, completion: nil)
            delayCounter += 1;
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        bannerView.delegate = self
        bannerView.adUnitID = "ca-app-pub-8919920204791449/6314962307";
        bannerView.rootViewController = self
        
        
        
        
        btn.layer.cornerRadius = btn.frame.size.width / 2
        
        btn.isEnabled = false;
        btn.isHidden = true;
        
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "logo_skull"));
        
        

           //절대좌표 //버튼 위치 잡기
           let btn_center_x = self.navigationController?.navigationBar.frame.maxX;
           let btn_center_y = self.navigationController?.navigationBar.frame.maxY;
           
        
           //버튼 크기
           let btn_width_size = btn.bounds.size.width;
           let btn_height_size = btn.bounds.size.height;
           
           
           //트랜지션 애니메이션 열릴 좌표 구하기
           let btn_trasition_point_x = btn_center_x! - btn_width_size/2 - 16;
           let btn_trasition_point_y = btn_center_y! - btn_height_size/2;
           
           
           btn_trasition_point = CGPoint(x: btn_trasition_point_x, y: btn_trasition_point_y)
        
        
        
        //UserDefaults.standard.set(false, forKey: "first");
        //최초 1회 실행
        let first = UserDefaults.standard.object(forKey: "first") as? Bool ?? false;
        
        if !first{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                let alertController = UIAlertController(title: NSLocalizedString("app", comment: "app"), message: NSLocalizedString("password", comment: "password"), preferredStyle: .alert)
                
                
                let  okButton = UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
                    self.performSegue(withIdentifier: "nuriView", sender: self);
                    
                })
                
                let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                    //print("Cancel button tapped")
                })
                
                
                alertController.addAction(okButton)
                alertController.addAction(cancelButton)
                
                self.present(alertController, animated: true, completion: nil)
            }
            UserDefaults.standard.set(true, forKey: "first");
        }

       
        
        
        //메모 초기화
//        UserDefaults.standard.removeObject(forKey: "memoData");
//        UserDefaults.standard.removeObject(forKey: "memoNumber");
//        UserDefaults.standard.removeObject(forKey: "memoLastNumber");
//        UserDefaults.standard.removeObject(forKey: "memoSequence");
//        UserDefaults.standard.removeObject(forKey: "searchActive");
//        UserDefaults.standard.removeObject(forKey: "searchText");
        
        UserDefaults.standard.set(false, forKey: "searchActive");
        
        //split뷰에서 아이폰에서 마스터 먼저 보이기
        self.splitViewController?.delegate = self;
        self.splitViewController?.preferredDisplayMode = UISplitViewControllerDisplayMode.allVisible;
        
        
        
        //split뷰의 사이즈 늘리기
//        self.splitViewController?.preferredPrimaryColumnWidthFraction = 0.35;
//        //self.splitViewController?.maximumPrimaryColumnWidth = (splitViewController?.view.bounds.size.width)!;
//        
//        let minimumWidth:CGFloat = min(splitViewController!.view.bounds.width,splitViewController!.view.bounds.height);
//        self.splitViewController?.minimumPrimaryColumnWidth = minimumWidth / 3.5;
//        self.splitViewController?.maximumPrimaryColumnWidth = minimumWidth;
        
        
        
        //table reload 옵저버
        let name = Notification.Name("table_reload");
        NotificationCenter.default.addObserver(self, selector: #selector(table_reload), name: name, object: nil)
        
        //프제젠테이션 정리 ( 셀 클릭시도 넣어줘야함 )
        self.definesPresentationContext = true
        
        resultSearchController = ({
            // 1
            let controller = UISearchController(searchResultsController: nil)
            // 2
            controller.searchResultsUpdater = self
            // 3
            controller.hidesNavigationBarDuringPresentation = false
            // 4
            controller.dimsBackgroundDuringPresentation = false
            // 5
            controller.searchBar.searchBarStyle = UISearchBarStyle.prominent
            // 6
            controller.searchBar.sizeToFit()
            
            controller.searchBar.placeholder = NSLocalizedString("search", comment: "search");
            
            
            controller.searchBar.backgroundImage = UIImage();
            controller.searchBar.isTranslucent = true;
            
            //클릭시 취소 버튼 색상
            controller.searchBar.barTintColor = UIColor.lightText;
            
            
            
            
            
            
            //텍스트필드 창
            let textFieldInsideSearchBar = controller.searchBar.value(forKey: "searchField") as? UITextField
            
            //placeholder 라벨
            let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
            textFieldInsideSearchBarLabel?.textColor = UIColor.lightGray;
            
            //textFieldInsideSearchBar?.textColor = UIColor.red;
            textFieldInsideSearchBar?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
            textFieldInsideSearchBar?.borderStyle = UITextBorderStyle.roundedRect;
            
            
            
            //검색 아이콘 색 변경
            let glassIconView = textFieldInsideSearchBar?.leftView as! UIImageView
            glassIconView.image = glassIconView.image?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
            //glassIconView.tintColor = UIColor.lightGray
            
            
            
            
            // 7
            self.tableView.tableHeaderView = controller.searchBar
            
            //테이블뷰의 백그라운드를 뷰로 대체
            self.tableView.backgroundView = UIView();
            
            self.tableView.contentOffset = CGPoint(x: 0, y: controller.searchBar.frame.height)
            // 8
            return controller
            
        })()
        
        
        //검색창 작동시 네비게이션바 안숨기기
        resultSearchController.hidesNavigationBarDuringPresentation = false;
        //검색창 작동시 뒷배경 흐리게 하는거 못하게
        resultSearchController.dimsBackgroundDuringPresentation = false;
        //검색창 델리게이트 추가
        resultSearchController.searchBar.delegate = self as? UISearchBarDelegate;
        
        
        

        
        //순서 불러오기
        memoSequence = UserDefaults.standard.object(forKey: "memoSequence") as? [Int] ?? [Int]();
        
        //커스텀 클래스 불러오기
        let data = UserDefaults.standard.object(forKey: "memoData") as? Data ?? Data();
        memoData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [memoValue] ?? [memoValue]();

        
        
        
        
        //테이블 백그라운드 투명
        self.tableView.backgroundColor = UIColor.clear
        
        //테이블 빈셀 가리기
        tableView.tableFooterView = UIView(frame: CGRect.zero);
        
        
     
        //백그라운드 그라데이션 설정 // 다크 or 라이트
        background_gradation_update();

        
        
        //에디트버튼 바꾸기
        //self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
        
        //당기면 새로고침 컨트롤
        //tableView.refreshControl = refreshControl;
        //refreshControl.addTarget(self, action: #selector(Main.didRefresh), for: UIControlEvents.valueChanged)
        
        
        
        
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
        
        
        //뷰에 등록된 레이어들 삭제하기
        for layer in self.view.layer.sublayers! {
            if layer.name == "gradation_back" {
                 layer.removeFromSuperlayer()
            }
        }
        
        self.view.layer.insertSublayer(background, at: 0)
    }
    
    func didRefresh(){
        
        var timer:Timer?
        //1초 뒤에 실행
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: "dlsnfl", repeats: false);
        
        
    }
    
    @objc func update(timer : Timer){
        let parameter:String = timer.userInfo as! String ;
        //print(parameter)
        tableView.reloadData();
        //refreshControl.endRefreshing();
    }
    
    
    var add_bool : Bool = false;
    @IBAction func addClick(_ sender: Any) {
        
        add_bool = true;
        
        tableView.setEditing(false,animated: true);
        
        UserDefaults.standard.set(-1, forKey: "memoNumber");
        
        self.performSegue(withIdentifier: "toWrite", sender: self)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        
        bannerView.load(GADRequest());
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        add_bool = false;
        
               
        
        
        
        //print("appear");
        if UserDefaults.standard.object(forKey: "searchActive") as? Bool ?? Bool()
        {
            let serch_text = UserDefaults.standard.object(forKey: "searchText") as? String ?? String()
            filteredArray = memoData.filter { (value) -> Bool in
                
                let tmp: String = value.text
                
                //값 찾아서 필터에 넣기
                if tmp.range(of: serch_text, options: String.CompareOptions.caseInsensitive) != nil
                {
                    return true;
                }else{
                    //print("no data");
                    return false;
                }
                
            }
            
            
            if(filteredArray.count == 0){
                searchActive = false;
            } else {
                searchActive = true;
            }
            
            self.tableView.reloadData()
            

        }else{
            tableView.reloadData();
        }
        
        animateTable();
        
        
        
    }
   
    
    
    
//MARK: - Table
    
    //세션 갯수
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    
    //셀 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //커스텀 클래스 불러오기
        let data = UserDefaults.standard.object(forKey: "memoData") as? Data ?? Data();
        memoData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [memoValue] ?? [memoValue]();

        if searchActive{
            return filteredArray.count;
        }else{
            return memoData.count;
        }
        
    }
    
    //셀 연결
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let Cell = tableView.dequeueReusableCell(withIdentifier: "memoCell", for: indexPath) as! MainCell
        
        //커스텀 클래스 불러오기
        let data = UserDefaults.standard.object(forKey: "memoData") as? Data ?? Data();
        memoData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [memoValue] ?? [memoValue]();
        
        //순서 불러오기
        memoSequence = UserDefaults.standard.object(forKey: "memoSequence") as? [Int] ?? [Int]();
        //거꾸로 index
        let i : Int = memoData.count - indexPath.row - 1;
        
        let memoNumber2 : Int = memoSequence[i];
        
        
        //포멧 시간
        let form = DateFormatter();
        var dateType:String = "";
        var stringDate:String = "";
        
        form.amSymbol="AM";
        form.pmSymbol = "PM";
        dateType = "yyyy. MM. dd. ";
        form.dateFormat = dateType;
        stringDate = form.string(from: memoData[i].date);
        

        if memoData.count != 0{
            
            
            
            //셀 백그라운드 바꾸기
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(red: (87/255.0), green: (150/255.0), blue: (240/255.0), alpha: 0.15)
            Cell.selectedBackgroundView = backgroundView
            
            if searchActive{
                //거꾸로 index
                let z : Int = filteredArray.count - indexPath.row - 1;
                
                //문자열 나누기
                let testArr = filteredArray[z].text.components(separatedBy: "\n")
                var text = String();
                
                for k in 1..<testArr.count{
                    text = testArr[k]
                    if text.isEmpty{
                        continue;
                    }else{
                        break;
                    }
                }
                if text.isEmpty{
                    text = NSLocalizedString("addText", comment: "addText");
                }
                
                
                Cell.titleLabel.text = filteredArray[z].text;
                Cell.subTitleLabel.text = stringDate;
                Cell.additionalText.text = text;
                
                    
                    
            }else{
                //WHERE 문으로 인덱스값 찾기
                if let z = memoData.index(where: { $0.memoNumber == memoNumber2 }) {
                    
                    //print("메모 index : \(z)")
                    
                    //문자열 나누기
                    let testArr = memoData[z].text.components(separatedBy: "\n")
                    var text = String();
                    
                    for k in 1..<testArr.count{
                        text = testArr[k]
                        if text.isEmpty{
                            continue;
                        }else{
                            break;
                        }
                    }
                    if text.isEmpty{
                        text = NSLocalizedString("addText", comment: "addText");
                    }
                    
                    
                    Cell.titleLabel.text = memoData[z].text;
                    Cell.subTitleLabel.text = stringDate;
                    Cell.additionalText.text = text;
                    //Cell.tag = indexPath.row;
                    
                }else{
                    print("메모에서 찾을 수 없습니다.");
                }
            }

            
            
        
        }
            
        //Cell.textLabel?.text = "TableView Test"
        return Cell;
        
    }
    
    //셀 선택 취소
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        let deselectedCell = tableView.cellForRow(at: indexPath)!
//        deselectedCell.backgroundColor = UIColor.clear
        
    }
    
    //셀 선택
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        add_bool = false;
        
                
        
        //self.performSegue(withIdentifier: "toWrite", sender: self);
//       
//        
//        memoSequence = UserDefaults.standard.object(forKey: "memoSequence") as? [Int] ?? [Int]();
//
//        //부모보다 뒤에
//        self.definesPresentationContext = true
//        
//        if searchActive{
//            //거꾸로 index
//            let i : Int = filteredArray.count - indexPath.row - 1;
//
//            
//            //테이블 인덱스값
//            let memoNumber2 = filteredArray[i].memoNumber;
//            UserDefaults.standard.set(memoNumber2, forKey: "memoNumber");
//            
//            UserDefaults.standard.set(true, forKey: "searchActive");
//            
//            
//            
//            //self.performSegue(withIdentifier: "toWrite", sender: self)
//        }else{
//            //거꾸로 index
//            let i : Int = memoSequence.count - indexPath.row - 1;
//
//            
//            //테이블 인덱스값
//            let memoNumber2 = memoSequence[i];
//            UserDefaults.standard.set(memoNumber2, forKey: "memoNumber");
//            
//            
//            //self.performSegue(withIdentifier: "toWrite", sender: self)
//        }
        
        
        
        
    }
    
    
    
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        
        
        
        
        transition.transitionMode = .present
        transition.startingPoint = btn_trasition_point;
        //transition.circleColor = btn.backgroundColor!;
        
        //다크모드 체크
        if #available(iOS 12.0, *) { //12버전 이상일때
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                transition.circleColor = UIColor(red: 28 / 255.0, green: 28 / 255.0, blue: 30 / 255.0, alpha: 1.0);
            } else {
                // User Interface is Light
                transition.circleColor = UIColor(red: 239 / 255.0, green: 239 / 255.0, blue: 244 / 255.0, alpha: 1.0);
            }
        } else {
            // Fallback on earlier versions
            transition.circleColor = UIColor(red: 239 / 255.0, green: 239 / 255.0, blue: 244 / 255.0, alpha: 1.0);
        }
        
        //print("시작");
        
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = btn_trasition_point;
        //transition.circleColor = btn.backgroundColor!;
        
    
        
        //다크모드 체크
        if #available(iOS 12.0, *) { //12버전 이상일때
            if self.traitCollection.userInterfaceStyle == .dark {
                // User Interface is Dark
                transition.circleColor = UIColor(red: 28 / 255.0, green: 28 / 255.0, blue: 30 / 255.0, alpha: 1.0);
            } else {
                // User Interface is Light
                transition.circleColor = UIColor(red: 239 / 255.0, green: 239 / 255.0, blue: 244 / 255.0, alpha: 1.0);
            }
        } else {
            // Fallback on earlier versions
            transition.circleColor = UIColor(red: 239 / 255.0, green: 239 / 255.0, blue: 244 / 255.0, alpha: 1.0);
        }
        
        //print("끝");
        
        return transition
        
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "nuriView" {
            let secondVC = segue.destination as! UINavigationController
            secondVC.transitioningDelegate = self as UIViewControllerTransitioningDelegate
            secondVC.modalPresentationStyle = .custom
        }
        
        if segue.identifier == "toWrite" {
            
            
            let nav = segue.destination as! UINavigationController;
            let vc = nav.viewControllers[0] as! Write;
            
            
            
            
            memoNumber = UserDefaults.standard.object(forKey: "memoNumber") as? Int ?? Int();
            
            
            memoSequence = UserDefaults.standard.object(forKey: "memoSequence") as? [Int] ?? [Int]();
            var mm:Int = Int();
            
            //부모보다 뒤에
            self.definesPresentationContext = true
            
            if add_bool == false{
                let indexPath = tableView.indexPathForSelectedRow ?? IndexPath();
                //선택셀 태그 가져오기
                print(tableView.cellForRow(at: indexPath)?.tag ?? 0)
                
                if searchActive{
                    //거꾸로 index
                    let i : Int = filteredArray.count - indexPath.row - 1;
                    
                    
                    //테이블 인덱스값
                    mm = filteredArray[i].memoNumber;
                    UserDefaults.standard.set(mm, forKey: "memoNumber");
                    
                    UserDefaults.standard.set(true, forKey: "searchActive");
                    
                }else{
                    //거꾸로 index
                    
                    let i : Int = memoSequence.count - indexPath.row - 1;
                    
                    
                    //테이블 인덱스값
                    mm = memoSequence[i];
                    UserDefaults.standard.set(mm, forKey: "memoNumber");
                    
                }
                
                vc.navigationItem.title = NSLocalizedString("memo", comment: "memo");
                
            }else{
                vc.navigationItem.title = NSLocalizedString("new", comment: "new");
                add_bool = false;
            }
            
            //테이블 선택해제
            //self.tableView.deselectRow(at: index, animated: true);
        }
    }
    
    //테이블 셀 슬라이드창
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            
            memoSequence = UserDefaults.standard.object(forKey: "memoSequence") as? [Int] ?? [Int]();
            
            //거꾸로 index
            let i : Int = memoSequence.count - indexPath.row - 1;
            
            //테이블 인덱스값
            let memoNumber2 = memoSequence[i];
            
            //WHERE 문으로 인덱스값 찾기
            if let i = self.memoData.index(where: { $0.memoNumber == memoNumber2 }) {
                print("메모 index : \(i)")
                self.memoData.remove(at: i);
                
                //메모데이타 저장
                let encodedData = NSKeyedArchiver.archivedData(withRootObject: self.memoData)
                UserDefaults.standard.set(encodedData, forKey: "memoData")
                
                //메모장 삭제되었으면 순서에서도 삭제
                if let i = self.memoSequence.index(of: memoNumber2 ) {
                    print("순서 index : \(i)")
                    self.memoSequence.remove(at: i);
                    
                    //순서저장
                    UserDefaults.standard.set(self.memoSequence, forKey: "memoSequence")
                }else{
                    print("순서에서 찾을 수 없습니다.");
                }
                
                
            }else{
                print("메모에서 찾을 수 없습니다.");
            }
            
                        
            //테이블 행 삭제
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            
            //detail view 초기화
            let noti = Notification.init(name : Notification.Name(rawValue: "detail_init"));
            NotificationCenter.default.post(noti);
            
   
            
        }
    }
    
    
    
    
    //에디트 스타일 왼쪽부분 생기기 (true) 없애기(false)
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    
    //테이블셀 에디팅 스타일
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    
    //테이블셀 이동
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        if(sourceIndexPath.row != destinationIndexPath.row)
        {
            
            memoSequence = UserDefaults.standard.object(forKey: "memoSequence") as? [Int] ?? [Int]();
            
            //거꾸로
            let start = memoSequence.count - sourceIndexPath.row - 1;
            let end = memoSequence.count - destinationIndexPath.row - 1;
            print(start);
            print(end);
            
            var itemToMove : Int = Int();
            itemToMove = memoSequence[start];
            print(itemToMove);
            
            memoSequence.remove(at: start);
            memoSequence.insert(itemToMove, at: end);
            
            //순서저장
            UserDefaults.standard.set(memoSequence, forKey: "memoSequence")
 

            
            
        }
    }
    
    
//    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let  headerCell = tableView.dequeueReusableCellWithIdentifier("HeaderCell") as! CustomHeaderCell
//        headerCell.backgroundColor = UIColor.cyanColor()
//        
//        switch (section) {
//        case 0:
//            headerCell.headerLabel.text = "Europe";
//        //return sectionHeaderView
//        case 1:
//            headerCell.headerLabel.text = "Asia";
//        //return sectionHeaderView
//        case 2:
//            headerCell.headerLabel.text = "South America";
//        //return sectionHeaderView
//        default:
//            headerCell.headerLabel.text = "Other";
//        }
//        
//        return headerCell
//    }
    
    
    //섹션 header 초기화
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "memoHeader") as! MainHeaderCell
        //headerCell.headerCell.textColor = UIColor.white;
        headerCell.backgroundColor = UIColor(red: (219/255.0), green: (244/255.0), blue: (254/255.0), alpha: 1.000)
        
        
        switch (section) {
        case 0:
            headerCell.headerCell.text = "memo";
        //return sectionHeaderView
        case 1:
            headerCell.headerCell.text = "Europe";
        //return sectionHeaderView
        case 2:
            headerCell.headerCell.text = "Europe";
        //return sectionHeaderView
        default:
            headerCell.headerCell.text = "Other";
        }
        
        return headerCell
    }
    
    //섹션 Header 높이설정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0;
    }
    
    //섹션 footer 초기화
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
       
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40) )
        footerView.backgroundColor = UIColor.clear;
        
        return footerView
    }
    //섹션 footer height
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    
    
//Table_End
    
    
    
    //MARK: - SearchBar
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filteredArray = memoData.filter { (value) -> Bool in
            
            let tmp: String = value.text
            
            //값 찾아서 필터에 넣기
            if tmp.range(of: searchController.searchBar.text!, options: String.CompareOptions.caseInsensitive) != nil
            {
                return true;
            }else{
                //print("no data");
                return false;
            }
            
        }
        
        
        if(filteredArray.count == 0){
            searchActive = false;
        } else {
            searchActive = true;
        }
        
        self.tableView.reloadData()
        
        UserDefaults.standard.set(searchController.searchBar.text!, forKey: "searchText");
    }
    
    
    //검색창 클릭
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        //텍스트필드 창
        let textFieldInsideSearchBar = resultSearchController.searchBar.value(forKey: "searchField") as? UITextField
    
        UIView.animate(withDuration: 0.2,
                       delay:0,
                       options:UIViewAnimationOptions.curveEaseIn,
                       animations: {
                        //self.resultSearchController.searchBar.barTintColor = UIColor.lightText;
                        
                        //검색 취소글씨 색깔 바꾸기
                        
                        /*
                        self.resultSearchController.searchBar.setShowsCancelButton(true, animated: true)
                        for ob: UIView in ((searchBar.subviews[0] )).subviews {
                            
                            if let z = ob as? UIButton {
                                let btn: UIButton = z
                                btn.setTitleColor(UIColor(red: 52/255.0, green: 120/255.0, blue: 246/255.0, alpha: 1.0), for: .normal)
                            }
                        }
                         */
                        
                        textFieldInsideSearchBar?.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05)
        }, completion: { (finished) -> Void in
            //print("end");
        })

        
    }
    
    
    //검색창 취소
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
       
        //텍스트필드 창
        let textFieldInsideSearchBar = resultSearchController.searchBar.value(forKey: "searchField") as? UITextField
        
        UIView.animate(withDuration: 0.2,
                       delay:0,
                       options:UIViewAnimationOptions.curveEaseIn,
                        animations: {
                            
                            //취소글씨
                            //self.resultSearchController.searchBar.barTintColor = UIColor(red: (154/255.0), green: (216/255.0), blue: (252/255.0), alpha: 1.000)
                            textFieldInsideSearchBar?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        }, completion: { (finished) -> Void in
            //print("end");
        })
        

    }
    
    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.showsCancelButton = true;
//        filteredArray = [memoValue]();
//        
//        //searchActive = true;
//    }
//    
//    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
//        searchActive = false;
//    }
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchActive = false;
//        searchBar.text = nil
//        searchBar.showsCancelButton = false
//        
//        searchBar.endEditing(true)
//        UserDefaults.standard.set(false, forKey: "searchActive");
//        tableView.reloadData()
//    }
//    
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchActive = false;
//        
//    }
//    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        
//        
//        filteredArray = memoData.filter { (value) -> Bool in
//            
//            let tmp: String = value.text
//            
//            //값 찾아서 필터에 넣기
//            if tmp.range(of: searchText, options: String.CompareOptions.caseInsensitive) != nil
//            {
//                return true;
//            }else{
//                //print("no data");
//                return false;
//            }
//            
//        }
//        
//        
//        if(filteredArray.count == 0){
//            searchActive = false;
//        } else {
//            searchActive = true;
//        }
//        
//        self.tableView.reloadData()
//        
//    }
    
    //SearchBar_End
    
    
    //에디팅 버튼 함수
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        if editing{
            tableView.setEditing(true, animated: true);
        }else{
            tableView.setEditing(false,animated: true);
        }
        
    }
    
    
    
    // MARK: - GADBannerViewDelegate
    // Called when an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called when an ad request failed.
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("\(#function): \(error.localizedDescription)")
    }
    
    // Called just before presenting the user a full screen view, such as a browser, in response to
    // clicking on an ad.
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before dismissing a full screen view.
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just after dismissing a full screen view.
    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    // Called just before the application will background or terminate because the user clicked on an
    // ad that will launch another application (such as the App Store).
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print(#function)
    }
    
    
    

}

