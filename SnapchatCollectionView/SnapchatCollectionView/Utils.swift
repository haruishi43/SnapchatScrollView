//
//  Utils.swift
//  SnapchatCollectionView
//
//  Created by Haruya Ishikawa on 2018/04/12.
//  Copyright © 2018 Haruya Ishikawa. All rights reserved.
//

import Foundation

class Utils {
    /// isDateExpired: check given date string is expired or not at right now
    func isDateExpired(dateStr:String)->Bool{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:ii:ss"
        let date = dateFormatter.date(from: dateStr)
        if date == nil || date! > NSDate() as Date{
            return true
        }
        return false
    }
    
    func createName() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let fileName = formatter.string(from: now)
        return fileName
    }
}
