//
//  ManualRecordViewModel.swift
//  UMM
//
//  Created by Wonil Lee on 10/21/23.
//

import Foundation

class ManualRecordViewModel: ObservableObject {
    
    let viewContext = PersistenceController.shared.container.viewContext
    
    // MARK: - in-string property
    
    @Published var payAmount: Double = -1 {
        didSet {
//            payAmountInWon = ...
            payAmountInWon = payAmount * 9.1 // ^^^
        }
    }
    @Published var payAmountInWon: Double = -1

    @Published var info: String?
    @Published var category: ExpenseInfoCategory = .unknown
    @Published var paymentMethod: PaymentMethod = .unknown
    
    // MARK: - not-in-string property
    
    @Published var chosenTravel: Travel? = nil {
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
    
    @Published var participantTupleArray: [(String, Bool)] = [("나", true)]
    @Published var additionalParticipantTupleArray: [(String, Bool)] = []
    
    @Published var payDate: Date = Date()
    var currentDate: Date = Date()

    @Published var country: Country = .japan {
        didSet {
            locationExpression = country.name
        }
    }
    @Published var locationExpression: String = "일본 도쿄"
    var currentCountry: Country = .japan
    var currentLocation: String = "일본 도쿄"
    @Published var otherCountryCandidateArray: [Country] = [.usa]
    
    @Published var currency: Currency = .jpy {
        didSet {
//            payAmountInWon = ...
            payAmountInWon = payAmount * 910.0 // ^^^
        }
    }
    
    init() {
//        country = LocationHandler.shared.getCurrentCounty()
//        currentCountry = country
//        locationExpression = LocationHandler.shared.getCurrentLocation()
//        currentLocation = locationExpression
//        currency = CurrencyHandler.shard.getCurrency(country)
        country = .japan
        currentCountry = country
        locationExpression = "일본 도쿄"
        currentLocation = locationExpression
        currency = .jpy
    }
    
    func save() {
        
        let expense = Expense(context: viewContext)
        expense.category = Int64(category.rawValue)
        expense.country = Int64(country.rawValue)
        expense.currency = Int64(currency.rawValue)
//        expense.exchangeRate = CurrencyHandler.getExchangeRate(currency)
        expense.exchangeRate = 9.1 // ^^^
        expense.info = info
        expense.location = locationExpression
        expense.participantArray = participantTupleArray.filter { $0.1 == true }.map { $0.0 }
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
}
