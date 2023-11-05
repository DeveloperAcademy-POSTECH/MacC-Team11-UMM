//
//  CurrencyInfoModel.swift
//  UMM
//
//  Created by 김태현 on 11/6/23.
//

import Foundation

class CurrencyInfoModel {
    
    static let shared = CurrencyInfoModel()
    private init() {
    }
    
    lazy var CurrencyResult: [Int: CurrencyInfo] = {
            do {
                let csvURL = Bundle.main.url(forResource: "CurrencyList", withExtension: "csv")!
                return try createCurrencyInfoDictionary(from: csvURL)
            } catch {
                fatalError("Error parsing CSV file: \(error)")
            }
        }()
    
    // MARK: CSV파일 데이터 파싱
    func parseCSV(contentsOf url: URL) throws -> [[String]] {
        let data = try String(contentsOf: url)
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            let columns = row.components(separatedBy: ",")
            result.append(columns)
        }
        return result
    }

    // MARK: 인덱스(화폐 순서)와 CurrencyInfo 구조체를 딕셔너리 형태로 만들기
    func createCurrencyInfoDictionary(from csvURL: URL) throws -> [Int: CurrencyInfo] {
        let csvData = try parseCSV(contentsOf: csvURL)
        var CurrencyInfoDict: [Int: CurrencyInfo] = [:]
        
        for columns in csvData where columns.count >= 4 {
            let index = Int(columns[0]) ?? 0
            let isoCodeName = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let koreanName = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let symbolName = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
            
            let CurrencyInfo = CurrencyInfo(isoCodeNm: isoCodeName,
                                          koreanNm: koreanName,
                                            symbol: symbolName)
            
            CurrencyInfoDict[index] = CurrencyInfo
        }
        return CurrencyInfoDict
    }
}
