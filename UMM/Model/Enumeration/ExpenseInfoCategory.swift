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
            return "fun"
        case .shopping:
            return "shopping"
        default:
            return "unknown"
        }
    }
    
    var visibleDescription: String {
        switch self {
        case .plane:
            return "항공"
        case .room:
            return "숙소"
        case .transportation:
            return "교통"
        case .food:
            return "식비"
        case .fun:
            return "관광"
        case .shopping:
            return "쇼핑"
        default:
            return "기타"
        }
    }
    var manualRecordImageString: String {
        switch self {
        case .plane:
            return "manualRecordCategoryPlane"
        case .room:
            return "manualRecordCategoryRoom"
        case .transportation:
            return "manualRecordCategoryTransportation"
        case .food:
            return "manualRecordCategoryFood"
        case .fun:
            return "manualRecordCategoryFun"
        case .shopping:
            return "manualRecordCategoryShopping"
        default:
            return "manualRecordCategoryUnknown"
        }
    }
    
    var modalImageString: String {
        switch self {
        case .plane:
            return "modalCategoryPlane"
        case .room:
            return "modalCategoryRoom"
        case .transportation:
            return "modalCategoryTransportation"
        case .food:
            return "modalCategoryFood"
        case .fun:
            return "modalCategoryFun"
        case .shopping:
            return "modalCategoryShopping"
        default:
            return "modalCategoryUnknown"
        }
    }
}
