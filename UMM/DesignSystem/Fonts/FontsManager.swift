//
//  FontsManager.swift
//  UMM
//
//  Created by GYURI PARK on 2023/10/16.
//

import Foundation
import SwiftUI

struct FontsManager {
    struct Pretendard {
        static let black = "Pretendard-Black"
        static let bold = "Pretendard-Bold"
        static let extraBold = "Pretendard-ExtraBold"
        static let extraLight = "Pretendard-ExtraLight"
        static let light = "Pretendard-Light"
        static let medium = "Pretendard-Medium"
        static let regular = "Pretendard-Regular"
        static let semiBold = "Pretendard-SemiBold"
        static let thin = "Pretendard-Thin"
    }
}

let display1 = Font.custom(FontsManager.Pretendard.semiBold, size: 20)
let display2 = Font.custom(FontsManager.Pretendard.semiBold, size: 24)
let display3 = Font.custom(FontsManager.Pretendard.semiBold, size: 28)

let subhead1 = Font.custom(FontsManager.Pretendard.semiBold, size: 14)
let subhead2_1 = Font.custom(FontsManager.Pretendard.semiBold, size: 16)
let subhead2_2 = Font.custom(FontsManager.Pretendard.medium, size: 16)
let subhead3_1 = Font.custom(FontsManager.Pretendard.semiBold, size: 18)
let subhead3_2 = Font.custom(FontsManager.Pretendard.medium, size: 18)

let body2 = Font.custom(FontsManager.Pretendard.medium, size: 16)
let body3 = Font.custom(FontsManager.Pretendard.medium, size: 18)

let caption1 = Font.custom(FontsManager.Pretendard.medium, size: 12)
let caption2 = Font.custom(FontsManager.Pretendard.medium, size: 14)

let calendar1 = Font.custom(FontsManager.Pretendard.medium, size: 20)
let calendar2 = Font.custom(FontsManager.Pretendard.regular, size: 20)
