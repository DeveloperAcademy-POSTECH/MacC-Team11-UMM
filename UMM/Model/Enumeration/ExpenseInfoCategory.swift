//
//  ExpenseInfoCategory.swift
//  UMM
//
//  Created by Wonil Lee on 10/12/23.
//

enum ExpenseInfoCategory: Int {
    case unknown = -1
    case plane
    case room
    case transportation
    case food
    case fun
    case shopping
    
    var description: String {
        switch self {
        case .plane:
            return "plane"
        case .room:
            return "room"
        case .transportation:
            return "transportation"
        case .food:
            return "food"
        case .fun:
            return"fun"
        case .shopping:
            return"shopping"
        default:
            return"unknown"
        }
    }
}
