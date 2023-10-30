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

class ManualRecordViewModel: ObservableObject, TravelChoiceModalUsable, CategoryChoiceModalUsable {
    
    let viewContext = PersistenceController.shared.container.viewContext
    
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
    
    @Published var payAmount: Double = -1 { // passive
        didSet {
            if payAmount == -1 || currency == .unknown {
                payAmountInWon = -1
            } else {
                payAmountInWon = payAmount * currency.rate // ^^^
            }
        }
    }
    @Published var payAmountString = "" {
        didSet {
            if payAmountString == "" {
                payAmount = -1
            } else {
                payAmount = Double(payAmountString) ?? -1
            }
        }
    }
    @Published var payAmountInWon: Double = -1 // passive

    @Published var info: String? // passive
    @Published var infoString: String = "" {
        didSet {
            if infoString == "" {
                info = nil
            } else {
                info = infoString
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
    
    @Published var participantTupleArray: [(String, Bool)] = [("나", true)] // passive
    @Published var additionalParticipantTupleArray: [(String, Bool)] = []
    
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
                payAmountInWon = payAmount * currency.rate // ^^^
            }
        }
    }
    @Published var currencyCandidateArray: [Currency] = []
    @Published var newNameString: String = ""
    
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
    @Published var addingParticipant = false
    
    // MARK: - 프로퍼티 관리
    
    func setChosenTravel(as travel: Travel) {
        chosenTravel = travel
    }
    
    func setCategory(as category: ExpenseInfoCategory) {
        self.category = category
    }
}
