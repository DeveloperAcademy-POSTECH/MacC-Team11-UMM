//
//  String+Extension.swift
//  UMM
//
//  Created by Wonil Lee on 10/12/23.
//

extension String {
    func getCharacterFormArray() -> [CharacterForm] {
        var tempCharacterFormArray: [CharacterForm] = Array(repeating: .notNumeric, count: self.count)
        var ind: String.Index = self.startIndex
        for j in 0..<self.count {
            tempCharacterFormArray[j] = self[ind].getCharacterForm()
            ind = self.index(after: ind)
        }
        return tempCharacterFormArray
    }
}
