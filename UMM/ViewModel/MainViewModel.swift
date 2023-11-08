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
    
    // didSet으로 selection == 2일 때, default
    @Published var selection: Int = 1
    @Published var selectedTravel: Travel?
    @Published var selectedTravelInExpense: Travel?
    @Published var chosenTravelInManualRecord: Travel?
    
    private init() {
        print("mainViewModel init")
        selectedTravel = findCurrentTravel()
        selectedTravelInExpense = findCurrentTravel()
    }
    
    func navigationToRecordView() {
        self.selection = 1
    }
    
    func navigationToExpenseView() {
        self.selection = 2
    }
}
