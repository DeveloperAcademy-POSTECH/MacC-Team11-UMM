//
//  Constants.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/23.
//

import Foundation
import SwiftUI

struct Constants {
    static var travelCnt: Int {
        switch UIScreen.main.bounds.size {
        case CGSize(width: 375, height: 667):  // SE
            return 3
        default:
            return 6
        }
    }
    
    static var indicatorOffset: CGFloat {
        switch UIScreen.main.bounds.size {
        case CGSize(width: 375, height: 667):
            return 55
        default:
            return 125
        }
    }
    
    static var interimOffset: CGFloat {
        switch UIScreen.main.bounds.size {
        case CGSize(width: 375, height: 667):
            return 55
        default:
            return 95
        }
    }
    
    static var frameWidth: CGFloat? {
        switch UIScreen.main.bounds.size {
        case CGSize(width: 375, height: 667):
            return 100
        default:
            return 110
        }
    }
    
    static var frameHeight: CGFloat? {
        switch UIScreen.main.bounds.size {
        case CGSize(width: 375, height: 667):
            return 70
        default:
            return 80
        }
    }
}
