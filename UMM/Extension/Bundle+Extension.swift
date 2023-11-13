//
//  Bundle+Extension.swift
//  UMM
//
//  Created by 김태현 on 11/13/23.
//

import Foundation

extension Bundle {
    var exchangeRateAPIKey: String {
        get {
            guard let filePath = Bundle.main.path(forResource: "API_KEY", ofType: "plist") else {
                fatalError("Couldn't find file 'API_KEY.plist'.")
            }
            let plist = NSDictionary(contentsOfFile: filePath)
            
            guard let value = plist?.object(forKey: "EXCHANGERATE_KEY") as? String else {
                fatalError("Couldn't find key 'EXCHANGERATE_KEY' in 'API_KEY.plist'.")
            }
            return value
        }
    }
}
