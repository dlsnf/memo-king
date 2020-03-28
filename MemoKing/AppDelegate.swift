//
//  AppDelegate.swift
//  MemoKing
//
//  Created by Nu-Ri Lee on 2017. 4. 11..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit
import GoogleMobileAds

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //잠시 재우기
        Thread.sleep(forTimeInterval: 0.2)
        
       
        
        let navigationFont = UIFont(name: "AppleSDGothicNeo-Light", size: 18)!
        let navigationFontAttributes = [NSAttributedStringKey.font : navigationFont]
        
        UINavigationBar.appearance().titleTextAttributes = navigationFontAttributes
        
        //락스크린 활성화
        let passCode = UserDefaults.standard.object(forKey: "passCode") as? String ?? String();
        if passCode.isEmpty{
        }
        else{
            UserDefaults.standard.set(true, forKey: "password");
            UserDefaults.standard.set(true, forKey: "password2");
        }
        
        
        
        //애드몹
        GADMobileAds.configure(withApplicationID: "ca-app-pub-8919920204791449~1438040143")
        
        
        
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        //떠나기전
        let blur = UserDefaults.standard.object(forKey: "blur") as? Bool ?? false;
        if blur {
            //옵저버 포스트 날리기
            let noti = Notification.init(name : Notification.Name(rawValue: "blur_show"));
            NotificationCenter.default.post(noti);
        }else{
        }
        
        let passCode = UserDefaults.standard.object(forKey: "passCode") as? String ?? String();
        if passCode.isEmpty{
            
        }
        else{
            let noti4 = Notification.init(name : Notification.Name(rawValue: "save"));
            NotificationCenter.default.post(noti4);
            
            let noti3 = Notification.init(name : Notification.Name(rawValue: "keyBoardDisabled"));
            NotificationCenter.default.post(noti3);
            
            let noti2 = Notification.init(name : Notification.Name(rawValue: "passCodeViewDismiss"));
            NotificationCenter.default.post(noti2);
            
            let noti = Notification.init(name : Notification.Name(rawValue: "settingViewDismiss"));
            NotificationCenter.default.post(noti);
            
            
            UserDefaults.standard.set(true, forKey: "password");
            
            
            
        }
        
        
        
        
        
        
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        //떠난이후
        
        //락스크린 활성화
        let passCode = UserDefaults.standard.object(forKey: "passCode") as? String ?? String();
        if passCode.isEmpty{
        }
        else{
            UserDefaults.standard.set(true, forKey: "password");
        }
        
    }

    //다시들어올때 직전
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        //락스크린 활성화
        let passCode = UserDefaults.standard.object(forKey: "passCode") as? String ?? String();
        if passCode.isEmpty{
        }
        else{
            UserDefaults.standard.set(true, forKey: "password");
        }
    }

    //다시들어오기고 나서
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //들어오기 전
        
        
        
        
        let blur = UserDefaults.standard.object(forKey: "blur") as? Bool ?? false;
        if blur {
            //잠금화면
            let passCode = UserDefaults.standard.object(forKey: "passCode") as? String ?? String();
            if passCode.isEmpty{
                let noti = Notification.init(name : Notification.Name(rawValue: "blur_hide"));
                NotificationCenter.default.post(noti);
            }else{
                
            }
        }else{
        }
        
        
        
        //잠금화면
        let passCode = UserDefaults.standard.object(forKey: "passCode") as? String ?? String();
        if passCode.isEmpty{
        }
        else{
            //락스크린 활성화
            let lock = UserDefaults.standard.object(forKey: "password") as? Bool ?? false;
            if lock {
                
                //락스크린 중복 제거
                let lock2 = UserDefaults.standard.object(forKey: "password2") as? Bool ?? false;
                
                if lock2{
                    let noti2 = Notification.init(name : Notification.Name(rawValue: "lockScreen"));
                    NotificationCenter.default.post(noti2);
                    
                }
                
            }
            
            
        }
        
        
        
        
        
        
        
        
        
    }

    
    //강제종료시
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        
        //락스크린 활성화
        let passCode = UserDefaults.standard.object(forKey: "passCode") as? String ?? String();
        if passCode.isEmpty{
        }
        else{
            UserDefaults.standard.set(true, forKey: "password");
            UserDefaults.standard.set(true, forKey: "password2");
        }
        
    }


}

