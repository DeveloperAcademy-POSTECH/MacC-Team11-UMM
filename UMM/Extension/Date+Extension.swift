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
}
