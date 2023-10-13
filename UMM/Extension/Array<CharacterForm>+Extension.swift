//
//  Array<CharacterForm>+Extension.swift
//  UMM
//
//  Created by Wonil Lee on 10/12/23.
//

extension Array<CharacterForm> {
    func getSplitVarietyAndNumericPrefixCount() -> (SplitVariety, Int) {
        var splitVariety: SplitVariety = .allNumeric
        var numericPrefixCount = 0
        for i in 0..<self.count {
            if self[i] != .notNumeric {
                numericPrefixCount = i + 1
                continue
            }
            if self[i] == .notNumeric {
                splitVariety = .noNumericInterpretation
                break
            }
        }
        if splitVariety == .noNumericInterpretation && numericPrefixCount > 0 {
            splitVariety = .startsWithNumeric
        }
        return (splitVariety, numericPrefixCount)
    }
}
