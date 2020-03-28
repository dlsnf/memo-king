//
//  PassCodeClass.swift
//  PassCode
//
//  Created by Nu-Ri Lee on 2017. 5. 4..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

import AVFoundation
import AudioToolbox


class PassCodeLock{
    
    //패스워드
    var password : String = String();
    
    //임시 패스워드
    var temp_password : String = String();
    
    //입력받은 패스워드
    var inputPassword : [String] = [String]();
    
    //입력받는것 활성화
    var isInputPassword : Bool = true;

    
    var dots : [Dot] = [Dot]();
    var dotsView : UIView = UIView();
    
    var count : Int = 0;
    var maxCount : Int = Int();
    
    
    
    
    init(dots : [Dot], dotsView : UIView){
        self.dots = dots;
        self.dotsView = dotsView;
        
        maxCount = dots.count;
        
        
    }
    
    func hashSHA256(data:Data) -> Data? {
        var hashData = Data(count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = hashData.withUnsafeMutableBytes {digestBytes in
            data.withUnsafeBytes {messageBytes in
                CC_SHA256(messageBytes, CC_LONG(data.count), digestBytes)
            }
        }
        return hashData
    }
    
    
    
    func setPassword(_ num : String) -> Int{
        if isInputPassword {
            if count <= maxCount-1{
                inputPassword.append(num);
                animatePlacehodlerAtIndex(count, toState: .active)
                
                count += 1;
            }
            
            if count == maxCount{
                if temp_password.isEmpty{
                    //1차 성공
                    temp_password = getInputPassword();
                    inputPassword.removeAll();
                    self.animatePlaceholders(self.dots, toState: .inactive);
                    self.count = 0;
                    return 1;
                }else{
                    if temp_password != getInputPassword(){
                        //비밀번호 안맞음
                        isInputPassword = false;
                        animatePlaceholders(dots, toState: .error);
                        dotsView.shake(duration: 0.4);
                        AudioServicesPlaySystemSound(1521) // Actuate `Nope` feedback (series of three weak booms)
                        
                        
                        //딜레이
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                            self.inputPassword.removeAll();
                            self.animatePlaceholders(self.dots, toState: .inactive);
                            self.isInputPassword = true;
                            self.count = 0;
                        }
                        
                        return 2;
                    }else{
                        //비밀번호 셋팅 성공
                        var pwCode : String = getInputPassword();
                        let clearData = pwCode.data(using:String.Encoding.utf8)!
                        let hash = hashSHA256(data:clearData)
                        pwCode = hash!.map { String(format: "%02hhx", $0) }.joined();
                        //print("hash: "+pwCode)
                        
                        UserDefaults.standard.set(pwCode, forKey: "passCode");
                        isInputPassword = false;
                        return 3;
                    }
                    
                }
            }
        }
        return 0;
    }
    
    
    func addPassword(_ num : String) -> Int{
        if isInputPassword {
            if count <= maxCount-1{
                inputPassword.append(num);
                animatePlacehodlerAtIndex(count, toState: .active)
            
                count += 1;
            }
            
            if count == maxCount{
                return checkPassword(pw: getInputPassword());
            }
        }
        return 0;
    }
    
    func checkPassword(pw : String) -> Int{
        
        //해시암호화
        var pwCode : String = pw;
        let clearData = pwCode.data(using:String.Encoding.utf8)!
        let hash = hashSHA256(data:clearData)
        pwCode = hash!.map { String(format: "%02hhx", $0) }.joined();
        
        
        if pwCode == password{
            //성공
            isInputPassword = false;
            return 2;
            
        }else{
            
            //실패
            isInputPassword = false;
            animatePlaceholders(dots, toState: .error);
            dotsView.shake(duration: 0.4);
            AudioServicesPlaySystemSound(1521) // Actuate `Nope` feedback (series of three weak booms)
            //딜레이
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                self.inputPassword.removeAll();
                self.animatePlaceholders(self.dots, toState: .inactive);
                self.isInputPassword = true;
                self.count = 0;
            }
            return 1;
        }
        
    }
    
    
    
    func getInputPassword() -> String{
        var password_temp : String = String();
        for pw in inputPassword{
            password_temp = password_temp + pw;
        }
        return password_temp;
    }
    
    func removePassword(){
        if isInputPassword {
            if count > 0{
                inputPassword.remove(at: count-1);
                animatePlacehodlerAtIndex(count-1, toState: .inactive)
                count -= 1;
            }
        }
    }
    
    //상태바꾸기
    fileprivate func animatePlacehodlerAtIndex(_ index: Int, toState state: Dot.State) {
        
        guard index < dots.count && index >= 0 else { return }
        
        dots[index].animateState(state)
    }
    
    //전체상태 바꾸기
    func animatePlaceholders(_ dots: [Dot], toState state: Dot.State) {
        
        for dot in dots {
            
            dot.animateState(state)
        }
    }
}
