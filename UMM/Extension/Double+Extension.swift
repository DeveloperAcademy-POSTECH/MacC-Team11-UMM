//
//  Double+Extension.swift
//  UMM
//
//  Created by Wonil Lee on 11/15/23.
//

import Foundation

extension Double {
    func getStringFraction0() -> String? {
        NumberFormatterHandler.shared.getStringFraction0(self)
    }
    
    func getStringFraction0To2() -> String? {
        NumberFormatterHandler.shared.getStringFraction0To2(self)
    }
}
