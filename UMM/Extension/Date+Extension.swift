//
//  Date+Extension.swift
//  UMM
//
//  Created by Wonil Lee on 10/17/23.
//

import Foundation

extension Date {
    func toString(dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        //        dateFormatter.timeZone = ...
        return dateFormatter.string(from: self)
    }
    
    func local000() -> Date {
        return DateGapHandler.shared.getLocal000(of: self)
    }
    
    func local235959() -> Date {
        return DateGapHandler.shared.getLocal235959(of: self)
    }
    
    func convertBeforeSaving() -> Date {
        return DateGapHandler.shared.convertBeforeSaving(date: self)
    }
    
    func convertBeforeShowing() -> Date {
        return DateGapHandler.shared.convertBeforeShowing(date: self)
    }
    
    func isTimeEqual(to otherDate: Date) -> Bool {
        let calendar = Calendar.current
        let componentsA = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        let componentsB = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: otherDate)
        
        return componentsA.year == componentsB.year &&
        componentsA.month == componentsB.month &&
        componentsA.day == componentsB.day &&
        componentsA.hour == componentsB.hour &&
        componentsA.minute == componentsB.minute
    }
}
