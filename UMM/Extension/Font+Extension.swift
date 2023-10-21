//
//  Font+Extension.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/18.
//

import Foundation
import SwiftUI

extension Font {
    static let display1 = Font.custom(FontsManager.Pretendard.semiBold, size: 20)
    static let display2 = Font.custom(FontsManager.Pretendard.semiBold, size: 24)
    static let display3 = Font.custom(FontsManager.Pretendard.semiBold, size: 28)
    static let display4 = Font.custom(FontsManager.Pretendard.semiBold, size: 32)
    
    static let subhead1 = Font.custom(FontsManager.Pretendard.semiBold, size: 14)
    static let subhead2_1 = Font.custom(FontsManager.Pretendard.semiBold, size: 16)
    static let subhead2_2 = Font.custom(FontsManager.Pretendard.medium, size: 16)
    static let subhead3_1 = Font.custom(FontsManager.Pretendard.semiBold, size: 18)
    static let subhead3_2 = Font.custom(FontsManager.Pretendard.medium, size: 18)
    
    static let body2 = Font.custom(FontsManager.Pretendard.medium, size: 16)
    static let body3 = Font.custom(FontsManager.Pretendard.medium, size: 18)
    
    static let caption1 = Font.custom(FontsManager.Pretendard.medium, size: 12)
    static let caption2 = Font.custom(FontsManager.Pretendard.medium, size: 14)
    
    static let calendar1 = Font.custom(FontsManager.Pretendard.medium, size: 20)
    static let calendar2 = Font.custom(FontsManager.Pretendard.regular, size: 20)
}
