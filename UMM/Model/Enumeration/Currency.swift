//
//  Currency.swift
//  UMM
//
//  Created by Wonil Lee on 10/17/23.
//

import Foundation

enum Currency: Int {
    case unknown = -1
    case krw // 한국 원
    case jpy // 엔화
    case eur // 유로화
    case gbp // 영국 파운드
    case usd // 미국 달러
    case twd // 신 대만 달러
    case cny // 중국 위안
    case vnd // 베트남 동
    
    var title: String {
        switch self {
        case .unknown:
            return "미분류"
        case .krw:
            return "원"
        case .jpy:
            return "엔"
        case .eur:
            return "유로"
        case .gbp:
            return "파운드"
        case .usd:
            return "달러"
        case .twd:
            return "대만 달러"
        case .cny:
            return "위안"
        case .vnd:
            return "동"
        }
    }
      
    var rate: Double {
        switch self {
        case .unknown:
            return 0
        case .krw:
            return 1
        case .usd:
            return 1353
        case .jpy:
            return 9.03
        case .eur:
            return 1433.37
        case .gbp:
            return 1645.86
        case .twd:
            return 41.83
        case .cny:
            return 184.65
        case .vnd:
            return 0.06
        }
    }
    
    var officialSymbol: String {
        switch self {
        case .unknown:
            return "?"
        case .krw:
            return "₩"
        case .jpy:
            return "¥"
        case .eur:
            return "€"
        case .gbp:
            return "£"
        case .usd:
            return "$"
        case .twd:
            return "$"
        case .cny:
            return "元"
        case .vnd:
            return "₫"
        }
    }
    
    static func getRate(of rawValue: Int) -> Double {
        guard let currency = Currency(rawValue: rawValue) else { return 0 }
        return currency.rate
    }
}
