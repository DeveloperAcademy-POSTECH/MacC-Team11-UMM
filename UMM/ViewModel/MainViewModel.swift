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
    var timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { timer in
        print("MainViewModel | selectedTravel: \(shared.selectedTravel?.name ?? "nilName")")
        print("MainViewModel | selectedTravelInExpense: \(shared.selectedTravelInExpense?.name ?? "nilName")")
    }
    
    // didSet으로 selection == 2일 때, default
    @Published var selection: Int = 1
    @Published var selectedTravel: Travel? {
        didSet {
            if selectedTravel?.name != tempTravelName {
                if selectedTravel != selectedTravelInExpense {
                    updateSelectedTravelInExpense()
                }
            }
        }
    }
    @Published var selectedTravelInExpense: Travel? {
        didSet {
            if selectedTravelInExpense != selectedTravel {
                updateSelectedTravel()
            }
        }
    }
    @Published var chosenTravelInManualRecord: Travel?
    var firstChosenTravelInManualRecord: Travel?
    
    private init() {
        print("mainViewModel init")
        selectedTravel = findCurrentTravel()
        if selectedTravel?.name ?? "" == tempTravelName {
            
        }
    }
    
    func navigationToRecordView() {
        self.selection = 1
    }
    
    func navigationToExpenseView() {
        self.selection = 2
    }
    
    func isSameFirstAndNowChosenTravel() -> Bool {
        return self.firstChosenTravelInManualRecord == self.chosenTravelInManualRecord
    }
    
    private func updateSelectedTravelInExpense() {
        selectedTravelInExpense = selectedTravel
    }
    
    private func updateSelectedTravel() {
        selectedTravel = selectedTravelInExpense
    }
}
