//
//  Helpers.swift
//  Mesrop-Test-App
//
//  Created by Mesrop Kareyan on 4/27/17.
//  Copyright © 2017 Mesrop Kareyan. All rights reserved.
//

import Foundation

extension Date {
    
    var  shortString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm"
        return dateFormatter.string(from: self)
    }
    
}

extension NSDate {
    
    var  shortString: String {
       let date = self as Date
        return date.shortString
    }
    
}
