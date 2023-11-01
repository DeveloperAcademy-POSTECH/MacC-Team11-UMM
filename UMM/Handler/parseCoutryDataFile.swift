//
//  parseCoutryDataFile.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/30.
//

import Foundation

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

// MARK: 인덱스(국가순서)와 국기 이미지 String값을 딕셔너리 형태로 만들기
//func createFlagImagesDictionary(from csvURL: URL) throws -> [Int64: String] {
//    let csvData = try parseCSV(contentsOf: csvURL)
//    var flagImages: [Int64: String] = [:]
//    for row in csvData {
//        if let number = Int(row[0]), let flagImage = row[safe: 4] {
//            flagImages[Int64(number)] = flagImage
//        }
//    }
//    return flagImages
//}

// MARK: flagImages를 유저 디폴트에 저장
//func saveFlagImagesToUserDefaults() {
//    do {
//        let csvURL = Bundle.main.url(forResource: "CountryList", withExtension: "csv")!
//        let flagImages = try createFlagImagesDictionary(from: csvURL)
//        
//        let encoder = PropertyListEncoder()
//        if let data = try? encoder.encode(flagImages) {
//            UserDefaults.standard.set(data, forKey: "flagImages")
//        } else {
//            print("Error encoding flagImages data.")
//        }
//    } catch {
//        print("Error saving flagImages to UserDefaults: \(error)")
//    }
//}

// MARK: 주어진 number에 해당하는 flagImage값 불러오기
//func getFlagImage(for number: Int64) -> String {
//    if let data = UserDefaults.standard.data(forKey: "flagImages") {
//        let decoder = PropertyListDecoder()
//        do {
//            let flagImages = try decoder.decode([Int64: String].self, from: data)
//            guard let flagImage = flagImages[number] else {
//                return "DefaultFlagImage"
//            }
//            return flagImage
//        } catch {
//            print("Error loading flagImages from UserDefaults: \(error)")
//        }
//    }
//    return "DefaultFlagImage"
//}

//extension Array {
//    subscript(safe index: Int64) -> Element? {
//        return indices ~= Int(index) ? self[Int(index)] : nil
//    }
//}
