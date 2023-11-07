//
//  MainViewModel.swift
//  UMM
//
//  Created by GYURI PARK on 2023/11/02.
//

import Foundation
import SwiftUI

class MainViewModel: ObservableObject {
    
    static let shared = MainViewModel()
    
    @Published var selection: Int = 0
    @Published var selectedTravel: Travel?
    @Published var chosenTravelInManualRecord: Travel?
    
    @Published var alertView_savedIsShown: Bool = false
    
    private init() {}
    
    func navigationToRecordView() {
        self.selection = 1
    }
    
    func navigationToExpenseView() {
        self.selection = 2
    }
}
