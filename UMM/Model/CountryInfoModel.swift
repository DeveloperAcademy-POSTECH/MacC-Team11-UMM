//
//  CountryInfoModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/02.
//

import Foundation

class CountryInfoModel {
    
    static let shared = CountryInfoModel()
    
    private init() {
        
    }
    
    lazy var countryResult: [Int: CountryInfo] = {
            do {
                let csvURL = Bundle.main.url(forResource: "CountryList", withExtension: "csv")!
                return try createCountryInfoDictionary(from: csvURL)
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

    // MARK: 인덱스(국가순서)와 CountryInfo 구조체를 딕셔너리 형태로 만들기
    func createCountryInfoDictionary(from csvURL: URL) throws -> [Int: CountryInfo] {
        let csvData = try parseCSV(contentsOf: csvURL)
        var countryInfoDict: [Int: CountryInfo] = [:]
        
        for columns in csvData where columns.count >= 6 {
            let index = Int(columns[0]) ?? 0
            let englishName = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let koreanName = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let locationName = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
            let flagImageName = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
            let defaultImageName = columns[5].trimmingCharacters(in: .whitespacesAndNewlines)
            
            let countryInfo = CountryInfo(englishNm: englishName,
                                          koreanNm: koreanName,
                                          locationNm: locationName,
                                          flagString: flagImageName,
                                          defaultImageString: defaultImageName)
            
            countryInfoDict[index] = countryInfo
        }
        return countryInfoDict
    }
}
