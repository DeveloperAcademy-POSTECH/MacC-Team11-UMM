//
//  Character+Extension.swift
//  UMM
//
//  Created by Wonil Lee on 10/12/23.
//

extension Character {
    static let arabicNumericArray: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    static let arabicCommaArray: [Character] = [","]
    static let arabicDotArray: [Character] = ["."]
    static let koreanNumericArray: [Character] = ["영", "일", "이", "삼", "사", "오", "육", "칠", "팔", "구"]
    static let koreanFourPowerArray: [Character] = ["만"]
    static let korean123PowerArray: [Character] = ["십", "백", "천"]
    static let koreanDotArray: [Character] = ["점"]
    
    func getCharacterForm() -> CharacterForm {
        if Character.arabicNumericArray.contains(self) {
            return .arabicNumeric
        } else if Character.arabicCommaArray.contains(self) {
            return .arabicComma
        } else if Character.arabicDotArray.contains(self) {
            return .arabicDot
        } else if Character.koreanNumericArray.contains(self) {
            return .koreanNumeric
        } else if Character.koreanFourPowerArray.contains(self) {
            return .koreanFourPower
        } else if Character.korean123PowerArray.contains(self) {
            return .korean123Power
        } else if Character.koreanDotArray.contains(self) {
            return .koreanDot
        } else {
            return .notNumeric
        }
    }
    
    func getCorrespondingArabicString() -> String {
        switch self {
            case "영":
                return "0"
            case "일":
                return "1"
            case "이":
                return "2"
            case "삼":
                return "3"
            case "사":
                return "4"
            case "오":
                return "5"
            case "육":
                return "6"
            case "칠":
                return "7"
            case "팔":
                return "8"
            case "구":
                return "9"
            default:
                return ""
        }
    }
}
