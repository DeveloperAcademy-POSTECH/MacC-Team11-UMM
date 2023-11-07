//
//  dateFormatter.swift
//  UMM
//
//  Created by 김태현 on 10/20/23.
//

import Foundation

let dateFormatterWithDay: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yy.MM.dd (E)"
    return formatter
}()

func dateFormatterWithHourMiniute(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    let timeString = formatter.string(from: date)
    return timeString
}

let dateFormatterWithHMS: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()
