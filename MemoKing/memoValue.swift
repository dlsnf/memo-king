//
//  memoValue.swift
//  MemoKing
//
//  Created by Nu-Ri Lee on 2017. 4. 17..
//  Copyright © 2017년 nuri lee. All rights reserved.
//

import Foundation

class memoValue: NSObject, NSCoding{
    
    var memoNumber : Int;
    var text : String;
    var date : Date;
    
    

    init(memoNumber : Int, text : String, date : Date){
        self.memoNumber = memoNumber;
        self.text = text;
        self.date = date;
    }
    
    required init(coder aDecoder: NSCoder) {
        self.memoNumber = Int(aDecoder.decodeInt32(forKey: "memoNumber"))
        self.text = aDecoder.decodeObject(forKey: "text") as! String
        self.date = aDecoder.decodeObject(forKey: "date") as! Date
        
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.memoNumber, forKey: "memoNumber")
        aCoder.encode(self.text, forKey: "text")
        aCoder.encode(self.date, forKey: "date")
    }
}
