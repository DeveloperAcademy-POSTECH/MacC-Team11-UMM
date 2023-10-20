//
//  PaymentMethod.swift
//  UMM
//
//  Created by Wonil Lee on 10/12/23.
//

enum PaymentMethod: Int {
    case unknown = -1
    case card
    case cash
    
    var title: String {
        switch self {
        case .unknown:
            return "미분류"
        case .card:
            return "카드"
        case .cash:
            return "현금"
        }
    }
    
    static func titleFor(rawValue: Int) -> String {
        return PaymentMethod(rawValue: rawValue)?.title ?? "전체"
    }
}
