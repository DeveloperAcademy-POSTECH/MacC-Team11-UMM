//
//  CSVArchive.swift
//  UMM
//
//  Created by 김태현 on 11/26/23.
//

import Foundation
import UniformTypeIdentifiers
import CoreTransferable

struct CSVArchive {
    var csvData: Data
    var fileName: String

    init(csvData: Data, fileName: String) {
        self.csvData = csvData
        self.fileName = fileName
    }
    
    func convertToCSV() throws -> Data {
        let csvDataFromSelectedTravel = csvData
        return csvDataFromSelectedTravel
    }
}

extension CSVArchive: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(contentType: .customCSV) { archive in
            try archive.convertToCSV()
        } importing: { data in
            CSVArchive(csvData: data, fileName: "test")
        }
        .suggestedFileName { document in
            document.fileName
        }
    }
}

extension UTType {
    static let customCSV = UTType(exportedAs: "com.example.csv")
}

extension CSVArchive {
    static func exportDataToCSV(travel: Travel) -> [Data] {
        let expenses = travel.expenseArray as? Set<Expense>
        let sortedExpenses = expenses?.sorted(by: { $0.payDate ?? Date.distantFuture < $1.payDate ?? Date.distantPast })
        
        var csvPage1: String = "여행 전/Day N/여행 후,지출 일시,지출 위치,카테고리,소비 내역,현지 결제 금액,원화 환산 금액,결제 수단,결제 인원\n"
        for expense in sortedExpenses ?? [] {
            
            let startDate = travel.startDate ?? Date.distantFuture
            let endDate = travel.endDate ?? Date.distantPast
            let payDateForJudgement = expense.payDate ?? Date.distantPast
            
            let travelState = payDateForJudgement < startDate ? "여행 전" : (payDateForJudgement <= endDate ? "Day \((Calendar.current.dateComponents([.day], from: startDate, to: payDateForJudgement).day ?? 0) + 1) " : "여행 후")
            
            let info = expense.info ?? "-"
            let payAmountWithCurrency = String(format: "%.0f", expense.payAmount) + (CurrencyInfoModel.shared.currencyResult[Int(expense.currency)]?.symbol ?? "-")
            
            let exchangeRate = expense.exchangeRate
            let exchangeRateString = String(format: "%.2f", exchangeRate)
            
            let payAmountInWon = expense.payAmount * expense.exchangeRate
            let payAmountInWonString = String(format: "%.0f", payAmountInWon)
            
            let payDate = expense.payDate?.toString(dateFormat: "yy.MM.dd(E) HH:mm") ?? Date.distantPast.toString(dateFormat: "yy.MM.dd(E) HH:mm")
            let paymentMethod = PaymentMethod.titleFor(rawValue: Int(expense.paymentMethod))
            let category = ExpenseInfoCategory.descriptionFor(rawValue: Int(expense.category))
            let participantString = "\"\(expense.participantArray?.joined(separator: ", ") ?? "")\""
            let countryAndLocatoinExpression = (CountryInfoModel.shared.countryResult[Int(expense.country)]?.koreanNm ?? "") + " " + (expense.location ?? "")
            
            let row = "\(travelState),\(payDate),\(countryAndLocatoinExpression),\(category),\(info),\(payAmountWithCurrency),\(payAmountInWonString),\(paymentMethod),\(participantString)\n"
            csvPage1.append(row)
        }
        
        var csvPage2: String = "이름,금액 합계\n"
        if let participants = travel.participantArray {
            let participantsWithMe = ["나"] + participants
            let totalSum = participantsWithMe.reduce(0.0) { sum, participant in
                let expenses = sortedExpenses?.filter { $0.participantArray?.contains(participant) ?? false }
                let totalExpense = expenses?.reduce(0, { (currentSum, expense) -> Double in
                    let participantCount = Double(expense.participantArray?.count ?? 1)
                    let dividedExpense = (expense.payAmount * expense.exchangeRate) / participantCount
                    return currentSum + dividedExpense
                }) ?? 0
                let totalExpenseString = String(format: "%.0f", totalExpense)
                
                let row = "\(participant),\(totalExpenseString)\n"
                csvPage2.append(row)
                
                return sum + totalExpense
            }
            
            let totalSumString = String(format: "%.0f", totalSum)
            csvPage2.append("총합,\(totalSumString),\n")
        }
        
//        let titleText = "본 문서의 한화 환산 금액은 지출 기록 시점의 환율을 기준으로 계산되어 실제 금액과 차이가 있을 수 있습니다."
//        let separator = "\n\n------------\n\n"
        
        let csvPageData1 = csvPage1.data(using: .utf8)
        let csvPageData2 = csvPage2.data(using: .utf8)
        
//        let combinedCSV = "\(titleText)\n\n\(csvPage1)\(separator)\(csvPage2)\n"
        
        guard let csvPageData1 = csvPageData1, let csvPageData2 = csvPageData2  else { return [] }
        return [csvPageData1, csvPageData2]
    }
}
