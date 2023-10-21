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
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter
}()

func dateFormmaterWithHourMiniute(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    let timeString = formatter.string(from: date)
    return timeString
}
