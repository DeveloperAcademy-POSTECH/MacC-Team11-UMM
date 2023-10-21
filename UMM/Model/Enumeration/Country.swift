//
//  Country.swift
//  UMM
//
//  Created by Wonil Lee on 10/17/23.
//

import Foundation

enum Country: Int {
    case unknown = -1
    case korea
    case japan
    case germany
    case uk
    case usa
    case france
    case taiwan
    case china
    case vietnam
    
    var title: String {
        switch self {
        case .unknown:
            return "미분류"
        case .korea:
            return "한국"
        case .japan:
            return "일본"
        case .germany:
            return "독일"
        case .uk:
            return "영국"
        case .usa:
            return "미국"
        case .france:
            return "프랑스"
        case .taiwan:
            return "대만"
        case .china:
            return "중국"
        case .vietnam:
            return "베트남"
        }
    }
    
    static func titleFor(rawValue: Int) -> String {
        return Country(rawValue: rawValue)?.title ?? "전체"
    }
}
