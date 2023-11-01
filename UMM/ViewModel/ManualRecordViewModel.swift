//
//  ManualRecordViewModel.swift
//  UMM
//
//  Created by Wonil Lee on 10/21/23.
//

import Foundation
import CoreLocation

class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var parent: ManualRecordViewModel?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        parent?.location = locations.first
        CLGeocoder().reverseGeocodeLocation(locations.first!) { placemarks, error in
            if let placemark = placemarks?.first {
                self.parent?.placemark = placemark
                self.parent?.currentCountry = Country.countryFor(isoCode: placemark.isoCountryCode ?? "") ?? .japan
                self.parent?.currentLocation = "\(placemark.locality ?? "")"
            } else {
                print("ERROR: \(String(describing: error?.localizedDescription))")
            }
        }
    }
}

class ManualRecordViewModel: ObservableObject {
    
    let viewContext = PersistenceController.shared.container.viewContext
    let exchangeHandler = ExchangeRateHandler.shared
    
    // MARK: - 위치 정보
    private var locationManager: CLLocationManager?
    private var locationManagerDelegate = LocationManagerDelegate()
    @Published var location: CLLocation?
    @Published var placemark: CLPlacemark?
    
    func getLocation() {
        print("ManualRecordViewModel | getLocation 호출됨 !!!")
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        locationManager.delegate = locationManagerDelegate
        locationManagerDelegate.parent = self

        // locationManager(_:didUpdateLocations:) 메서드가 호출될 때까지 기다림.
        while location == nil || placemark == nil {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
    }
    
    // MARK: - in-string property
    
    var payAmount: Double = -1 { // passive
        didSet {
            if payAmount == -1 || currency == .unknown {
                payAmountInWon = -1
            } else {
                payAmountInWon = payAmount * (exchangeHandler.getExchangeRateFromKRW(currencyCode: Currency.getCurrencyCodeName(of: Int(currency.rawValue))) ?? -1) // ^^^
            }
        }
    }
    @Published var visiblePayAmount: String = "" {
        didSet {
            var tempVisiblePayAmount = visiblePayAmount.filter { [.arabicNumeric, .arabicDot].contains($0.getCharacterForm()) }
            if let dotIndex = tempVisiblePayAmount.firstIndex(of: ".") {
                if let twoMovesIndex = tempVisiblePayAmount.index(dotIndex, offsetBy: 3, limitedBy: tempVisiblePayAmount.endIndex) {
                    tempVisiblePayAmount = String(tempVisiblePayAmount[..<twoMovesIndex])
                }
            }
            if visiblePayAmount != tempVisiblePayAmount {
                visiblePayAmount = tempVisiblePayAmount
            }
            
            if visiblePayAmount == "" {
                payAmount = -1
            } else {
                payAmount = Double(visiblePayAmount) ?? -1
            }
        }
    }
    @Published var payAmountInWon: Double = -1 // passive

    var info: String? // passive
    @Published var visibleInfo: String = "" {
        didSet {
            if visibleInfo == "" {
                info = nil
            } else {
                info = visibleInfo
            }
        }
    }
    
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
    
    @Published var participantTupleArray: [(name: String, isOn: Bool)] = [("나", true)] // passive
    @Published var additionalParticipantTupleArray: [(name: String, isOn: Bool)] = []
    
    @Published var payDate: Date = Date()
    var currentDate: Date = Date()

    @Published var country: Country = .japan {
        didSet {
            countryExpression = "\(country.title)"
            locationExpression = ""

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
    @Published var countryExpression: String = "" // passive
    @Published var locationExpression: String = ""
    var currentCountry: Country = .unknown
    var currentLocation: String = ""
    @Published var otherCountryCandidateArray: [Country] = [] // passive
    
    @Published var currency: Currency = .unknown {
        didSet {
            if payAmount == -1 || currency == .unknown {
                payAmountInWon = -1
            } else {
                payAmountInWon = payAmount * (exchangeHandler.getExchangeRateFromKRW(currencyCode: Currency.getCurrencyCodeName(of: Int(currency.rawValue))) ?? -1) // ^^^
            }
        }
    }
    @Published var currencyCandidateArray: [Currency] = []
    @Published var visibleNewNameOfParticipant: String = ""
    
    var soundRecordFileName: URL?
    
    // MARK: - view state
    
    @Published var recordButtonIsUsed = false
    @Published var travelChoiceModalIsShown = false
    @Published var categoryChoiceModalIsShown = false
    @Published var countryChoiceModalIsShown = false
    @Published var addingParticipant = false
    @Published var countryIsModified = false
    
    // MARK: - timer
    
    @Published var autoSaveTimer: Timer?
    @Published var secondCounter: Int?
    
    init() {
        locationManager = CLLocationManager()
        locationManager?.delegate = locationManagerDelegate
        locationManagerDelegate.parent = self
    }
    
    func save() {
        
        let expense = Expense(context: viewContext)
        expense.category = Int64(category.rawValue)
        expense.country = Int64(country.rawValue)
        expense.currency = Int64(currency.rawValue)
        expense.exchangeRate = exchangeHandler.getExchangeRateFromKRW(currencyCode: Currency.getCurrencyCodeName(of: Int(currency.rawValue))) ?? -1 // ^^^
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
}
