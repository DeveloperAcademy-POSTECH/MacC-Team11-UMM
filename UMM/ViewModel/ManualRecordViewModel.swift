//
//  ManualRecordViewModel.swift
//  UMM
//
//  Created by Wonil Lee on 10/21/23.
//

import Foundation

class ManualRecordViewModel: ObservableObject, TravelChoiceModalUsable, CategoryChoiceModalUsable {
    
    let viewContext = PersistenceController.shared.container.viewContext
    
    // MARK: - in-string property
    
    @Published var payAmount: Double = -1 {
        didSet {
            if payAmount == -1 || currency == .unknown {
                payAmountInWon = -1
            } else {
                payAmountInWon = payAmount * currency.rate // ^^^
            }
        }
    }
    @Published var payAmountInWon: Double = -1 // passive

    @Published var info: String?
    @Published var category: ExpenseInfoCategory = .unknown
    @Published var paymentMethod: PaymentMethod = .unknown
    
    // MARK: - not-in-string property
    
    @Published var chosenTravel: Travel? {
        didSet {
            if let chosenTravel {
                if let participantArrayInChosenTravel = chosenTravel.participantArray {
                    participantTupleArray = [("나", true)] + participantArrayInChosenTravel.map { ($0, true) }
                } else {
                    participantTupleArray = [("나", true)]
                }
                var expenseArray: [Expense] = []
                do {
                    try expenseArray = viewContext.fetch(Expense.fetchRequest()).filter { expense in
                        if let belongTravel = expense.travel {
                            return belongTravel.id == chosenTravel.id
                        } else {
                            return false
                        }
                    }
                } catch {
                    print("error fetching expenses: \(error.localizedDescription)")
                }
                otherCountryCandidateArray = Array(Set(expenseArray.map { Int($0.country) })).sorted().compactMap { Country(rawValue: $0) }
            } else {
                participantTupleArray = [("나", true)]
                otherCountryCandidateArray = []
            }
        }
    }
    @Published var travelArray: [Travel] = []
    
    @Published var participantTupleArray: [(String, Bool)] = [("나", true)] // passive
    @Published var additionalParticipantTupleArray: [(String, Bool)] = []
    
    @Published var payDate: Date = Date()
    var currentDate: Date = Date()

    @Published var country: Country = .japan {
        didSet {
            locationExpression = country.name // country와 연동하기 ^^^
            
            if country == .usa {
                currencyCandidateArray = [.usd, .krw]
            } else {
                currencyCandidateArray = country.relatedCurrencyArray
                if !currencyCandidateArray.contains(.usd) {
                    currencyCandidateArray.append(.usd)
                }
                if !currencyCandidateArray.contains(.krw) {
                    currencyCandidateArray.append(.krw)
                }
            }
            
            if currency == .usd && country != .usa {
                return
            } else if currency == .krw && country != .korea {
                return
            } else {
                currency = currencyCandidateArray.first ?? .usd
            }
        }
    }
    @Published var locationExpression: String = "" // passive
    var currentCountry: Country = .unknown
    var currentLocation: String = ""
    @Published var otherCountryCandidateArray: [Country] = [] // passive
    
    @Published var currency: Currency = .unknown {
        didSet {
            if payAmount == -1 || currency == .unknown {
                payAmountInWon = -1
            } else {
                payAmountInWon = payAmount * currency.rate // ^^^
            }
        }
    }
    @Published var currencyCandidateArray: [Currency] = []
    
    init() {
    }
    
    func save() {
        
        let expense = Expense(context: viewContext)
        expense.category = Int64(category.rawValue)
        expense.country = Int64(country.rawValue)
        expense.currency = Int64(currency.rawValue)
        expense.exchangeRate = currency.rate // ^^^
        expense.info = info
        expense.location = locationExpression
        expense.participantArray = (participantTupleArray + additionalParticipantTupleArray).filter { $0.1 == true }.map { $0.0 }
        expense.payAmount = payAmount
        expense.payDate = payDate
        expense.paymentMethod = Int64(paymentMethod.rawValue)
        expense.voiceRecordFile = nil // ^^^
        if let chosenTravel {
            var fetchedTravel: Travel?
            do {
                fetchedTravel = try viewContext.fetch(Travel.fetchRequest()).filter { travel in
                        return travel.id == chosenTravel.id
                }.first
            } catch {
                print("error fetching travelArray: \(error.localizedDescription)")
            }
            fetchedTravel?.lastUpdate = Date()
            fetchedTravel?.addToExpenseArray(expense)
        }
        do {
            try viewContext.save()
        } catch {
            print("error saving expense: \(error.localizedDescription)")
        }
    }
    
    // MARK: - view state
    
    @Published var travelChoiceModalIsShown = false
    @Published var categoryChoiceModalIsShown = false
    
    // MARK: - 프로퍼티 관리
    
    func setChosenTravel(as travel: Travel) {
        chosenTravel = travel
    }
    
    func setCategory(as category: ExpenseInfoCategory) {
        self.category = category
    }
}
