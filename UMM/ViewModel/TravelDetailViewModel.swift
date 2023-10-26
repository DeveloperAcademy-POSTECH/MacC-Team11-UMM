//
//  TravelDetailViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/27.
//

import Foundation

class TravelDetailViewModel: ObservableObject {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "YY.MM.dd (E)"
        
        return formatter
    }()
}
