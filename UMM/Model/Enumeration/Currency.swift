//    //
//    //  Currency.swift
//    //  UMM
//    //
//    //  Created by Wonil Lee on 10/17/23.
//    //
//
//    import Foundation
//
//    enum Currency: Int {
//        case unknown = -1
//        case krw // 한국 원
//        case jpy // 엔화
//        case eur // 유로화
//        case gbp // 영국 파운드
//        case usd // 미국 달러
//        case twd // 신 대만 달러
//        case cny // 중국 위안
//        case vnd // 베트남 동
//        
//        var title: String {
//            switch self {
//            case .unknown:
//                return "미분류"
//            case .krw:
//                return "원"
//            case .jpy:
//                return "엔"
//            case .eur:
//                return "유로"
//            case .gbp:
//                return "파운드"
//            case .usd:
//                return "달러"
//            case .twd:
//                return "대만 달러"
//            case .cny:
//                return "위안"
//            case .vnd:
//                return "동"
//            }
//        }
//        
//        var name: String {
//            switch self {
//            case .unknown:
//                return "unknown"
//            case .krw:
//                return "krw"
//            case .jpy:
//                return "jpy"
//            case .eur:
//                return "eur"
//            case .gbp:
//                return "gbp"
//            case .usd:
//                return "usd"
//            case .twd:
//                return "twd"
//            case .cny:
//                return "cny"
//            case .vnd:
//                return "vnd"
//            }
//        }
//        
//        var officialSymbol: String {
//            switch self {
//            case .unknown:
//                return "?"
//            case .krw:
//                return "₩"
//            case .jpy:
//                return "¥"
//            case .eur:
//                return "€"
//            case .gbp:
//                return "£"
//            case .usd:
//                return "$"
//            case .twd:
//                return "$"
//            case .cny:
//                return "元"
//            case .vnd:
//                return "₫"
//            }
//        }
//        
//        static func getSymbol(of rawValue: Int) -> String {
//            guard let currency = Currency(rawValue: rawValue) else { return "?" }
//            return currency.officialSymbol
//        }
//        
//        static func getCurrencyCodeName(of rawValue: Int) -> String {
//            guard let currency = Currency(rawValue: rawValue) else { return "unknown" }
//            return currency.name
//        }
//    }
