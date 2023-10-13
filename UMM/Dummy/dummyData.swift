//
//  dummyData.swift
//  UMM
//
//  Created by 김태현 on 10/12/23.
//

import Foundation

enum Currency: Int64 {
    case USD = 1
    case EUR = 2
    case JPY = 3
    case KRW = 4
    // 다른 화폐도 추가할 수 있습니다.
}

//struct DummyExpense: Identifiable {
//    var id = UUID()
//    var info: String?
//    var participant: [String]?
//    var payAmount: Double
//    var paymentMethod: Int64
//    var voiceRecordFile: String? // 고민 중 ...
//    var location: String
//    var currency: Int64
//    var exchangeRate: Double
//    var payDate: Date
//}

//let dummyExpenses: [Expense] = [
//    Expense(info: "여행", participant: ["John", "Alice"], payAmount: 50.0, paymentMethod: 1, voiceRecordFile: "voice1.mp3", location: "서울 여행", currency: 0, exchangeRate: 1.0, payDate: Date()),
//    Expense(info: "쇼핑", participant: ["Bob"], payAmount: 100.0, paymentMethod: 2, voiceRecordFile: "voice2.mp3", location: "Tokyo Travel", currency: 1, exchangeRate: 0.009, payDate: Date()),
//    Expense(info: "관광", participant: ["Charlie"], payAmount: 80.0, paymentMethod: 1, voiceRecordFile: "voice3.mp3", location: "명왕성 탐사", currency: 2, exchangeRate: 1.1, payDate: Date())
//]
