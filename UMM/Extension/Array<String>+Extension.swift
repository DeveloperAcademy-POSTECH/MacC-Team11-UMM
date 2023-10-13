//
//  Array<String>+Extension.swift
//  UMM
//
//  Created by Wonil Lee on 10/12/23.
//

extension Array<String> {
    func getUnifiedStringWithSpaceBetweenEachSplit() -> String {
        var temp = ""
        for str in self {
            temp += str
            temp += " "
        }
        if temp.count > 0 {
            temp.removeLast()
        }
        return temp
    }
}
