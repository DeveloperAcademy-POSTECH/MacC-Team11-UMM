//
//  MainViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/02.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    @Published var selection: Int = 0
    @Published var selectedTravel: Travel?
    
    func navigationToRecordView() {
        self.selection = 1
    }
    
    func navigationToExpenseView() {
        self.selection = 2
    }
}
