//
//  ExpenseInfoCategory.swift
//  UMM
//
//  Created by Wonil Lee on 10/12/23.
//

import SwiftUI

enum ExpenseInfoCategory: Int {
    case unknown = -1
    case plane
    case room
    case transportation
    case food
    case tour
    case shopping
    case gift
    
    var description: String {
        switch self {
        case .plane:
            return "항공"
        case .room:
            return "숙소"
        case .transportation:
            return "교통"
        case .food:
            return "식비"
        case .tour:
            return "관광"
        case .shopping:
            return "쇼핑"
        case .gift:
            return "선물"
        case .unknown:
            return "기타"
        }
    }
    
    var color: Color {
        switch self {
        case .plane:
            return Color("graphCyan")
        case .room:
            return Color("graphMagenta")
        case .transportation:
            return Color("graphYellow")
        case .food:
            return Color("graphOrange")
        case .tour:
            return Color("graphRed")
        case .shopping:
            return Color("graphPurple")
        case .gift:
            return Color("graphGreen")
        case .unknown:
            return Color("gray200")
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
        case .tour:
            return "관광"
        case .shopping:
            return "쇼핑"
        case .gift:
            return "선물"
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
        case .tour:
            return "manualRecordCategoryFun"
        case .shopping:
            return "manualRecordCategoryShopping"
        case .gift:
            return "manualRecordCategoryGift"
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
        case .tour:
            return "modalCategoryFun"
        case .shopping:
            return "modalCategoryShopping"
        case .gift:
            return "modalCategoryGift"
        default:
            return "modalCategoryUnknown"
        }
    }
      
    static func descriptionFor(rawValue: Int) -> String {
        return ExpenseInfoCategory(rawValue: rawValue)?.description ?? "전체"
    }
}
