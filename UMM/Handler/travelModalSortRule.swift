//
//  travelModalSortRule.swift
//  UMM
//
//  Created by Wonil Lee on 11/14/23.
//

import Foundation


let travelListSortRule: (Travel, Travel) -> Bool = {
    if let s0 = $0.startDate, let s1 = $1.startDate {
        s0 < s1
    } else {
        true
    }
}

let travelModalSortRule: (Travel, Travel) -> Bool = {
    let nowDate = Date()
    
    if $0.name != tempTravelName && $1.name == tempTravelName {
        return false
    } else if $0.name == tempTravelName && $1.name != tempTravelName {
        return true
    }
    
    let s0 = $0.startDate ?? Date.distantPast
    let e0 = $0.endDate ?? Date.distantFuture
    let s1 = $1.startDate ?? Date.distantPast
    let e1 = $1.endDate ?? Date.distantFuture
    
    enum TravelTimeState: Int {
        case current
        case past
        case coming
    }
    
    var state0 = TravelTimeState.current
    var state1 = TravelTimeState.current
    
    if s0 <= nowDate && nowDate <= e0 {
        state0 = .current
    } else if s0 > nowDate {
        state0 = .coming
    } else {
        state0 = .past
    }
    
    if s1 <= nowDate && nowDate <= e1 {
        state1 = .current
    } else if s1 > nowDate {
        state1 = .coming
    } else {
        state1 = .past
    }
    
    if state0 != state1 {
        return state0.rawValue < state1.rawValue
    } else { // 같은 상태의 두 여행
        if state0 == .current { // 진행 중 여행
            return s0 >= s1 // 시작일이 최신인 여행 먼저
        } else if state0 == .past { // 지난 여행
            return e0 >= e1 // 종료일이 최신인 여행 먼저
        } else { // 다가오는 여행
            return s0 <= s1 // 시작일이 과거인(가까운) 여행 먼저
        }
    }
}
