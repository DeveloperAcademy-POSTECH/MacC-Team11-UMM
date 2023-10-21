//
//  Currency.swift
//  UMM
//
//  Created by Wonil Lee on 10/17/23.
//

import Foundation

enum Currency: Int {
    case unknown = -1
    // 한국 원
    case krw
    // 미국 달러
    case usd
    // 엔화
    case jpy
    // 유로화
    case eur
    // 영국 파운드
    case gbp
    // 신 대만 달러
    case twd
    // 중국 위안
    case cny
    // 베트남 동
    case vnd
    
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
}
