//
//  NumberFormatterHandler.swift
//  UMM
//
//  Created by Wonil Lee on 11/15/23.
//

import Foundation

final class NumberFormatterHandler {
    static let shared = NumberFormatterHandler()
    
    let fraction0 = NumberFormatter()
    let fraction0To2 = NumberFormatter()
    
    private init() {
        fraction0.maximumFractionDigits = 0
        fraction0.numberStyle = .decimal
        
        fraction0To2.minimumFractionDigits = 0
        fraction0To2.maximumFractionDigits = 2
        fraction0To2.numberStyle = .decimal

    }
    
    func getStringFraction0(_ value: Double) -> String? {
        if let formatted = self.fraction0.string(from: NSNumber(value: value)) {
            return formatted
        } else {
            return nil
        }
    }
    func getStringFraction0To2(_ value: Double) -> String? {
        if let formatted = self.fraction0To2.string(from: NSNumber(value: value)) {
            return formatted
        } else {
            return nil
        }
    }
}
