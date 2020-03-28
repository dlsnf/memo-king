//
//  gradient.swift
//  MemoKing
//
//  Created by Nu-Ri Lee on 2017. 4. 18..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import UIKit

extension CAGradientLayer{
    
    func turquoiseColor() -> CAGradientLayer {
        
        let topColor: UIColor = UIColor(red: (143/255.0), green: (223/255.0), blue: (252/255.0), alpha: 1.000)
        let bottomColor: UIColor = UIColor(red: (212/255.0), green: (182/255.0), blue: (254/255.0), alpha: 1.000)
        
        let gradientColors : [CGColor] = [topColor.cgColor, bottomColor.cgColor];
        let gradientLocations : [Float] = [0.0, 1.0];
        
        let gradientLayer: CAGradientLayer = CAGradientLayer();
        gradientLayer.colors = gradientColors;
        gradientLayer.locations = gradientLocations as [NSNumber];
        
        return gradientLayer;
    }
    
    func turquoiseColorDark() -> CAGradientLayer {
        
        let topColor: UIColor = UIColor(red: (28/255.0), green: (28/255.0), blue: (30/255.0), alpha: 1.000)
        let bottomColor: UIColor = UIColor(red: (28/255.0), green: (28/255.0), blue: (30/255.0), alpha: 1.000)
        
        let gradientColors : [CGColor] = [topColor.cgColor, bottomColor.cgColor];
        let gradientLocations : [Float] = [0.0, 1.0];
        
        let gradientLayer: CAGradientLayer = CAGradientLayer();
        gradientLayer.colors = gradientColors;
        gradientLayer.locations = gradientLocations as [NSNumber];
        
        return gradientLayer;
    }
}



extension UIView {
    
    public func pauseAnimation(delay: Double) {
        let time = delay + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, time, 0, 0, 0, { timer in
            let layer = self.layer
            let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
            layer.speed = 0.0
            layer.timeOffset = pausedTime
        })
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
    }
    
    public func resumeAnimation() {
        let pausedTime  = layer.timeOffset
        
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
    }
}

