//
//  Configuration.swift
//  UMM
//
//  Created by 김태현 on 11/13/23.
//

import Foundation

enum Configuration {
    static let apiKey: String = {
        guard let filePath = Bundle.main.path(forResource: ".env", ofType: nil) else {
            fatalError("Couldn't find file '.env'")
        }
        let lines = try! String(contentsOfFile: filePath).split(separator: "\n")
        let key = lines[0].split(separator: "=")[1]
        return String(key)
    }()
}
