//
//  ManualRecordInExpenseViewModel.swift
//  UMM
//
//  Created by Wonil Lee on 10/21/23.
//

import AVFoundation
import Combine
import CoreLocation

class LocationManagerDelegateForExpense: NSObject, CLLocationManagerDelegate {
    var parent: ManualRecordInExpenseViewModel?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        parent?.location = locations.first
        CLGeocoder().reverseGeocodeLocation(locations.first!) { placemarks, error in
            if let placemark = placemarks?.first {
                self.parent?.placemark = placemark
                let code = placemark.isoCountryCode ?? ""
                let countryKey = CountryInfoModel.shared.countryResult.filter { tuple in
                    let pairCode = tuple.value.locationNm.components(separatedBy: "-")
                    if pairCode.count == 2 {
                        return pairCode[1] == code
                    } else {
                        return false
                    }
                }.first?.key ?? -1
                self.parent?.currentCountry = countryKey
                self.parent?.currentLocation = "\(placemark.locality ?? "")"
            } else {
                print("ERROR: \(String(describing: error?.localizedDescription))")
            }
        }
    }
}

final class ManualRecordInExpenseViewModel: NSObject, ObservableObject {
    
    let viewContext = PersistenceController.shared.container.viewContext
    let exchangeHandler = ExchangeRateHandler.shared
    var expenseId = ObjectIdentifier(NSObject())
    
    // MARK: - 위치 정보
    private var locationManager: CLLocationManager?
    private var locationManagerDelegate = LocationManagerDelegateForExpense()
    @Published var location: CLLocation?
    @Published var placemark: CLPlacemark?
    
    func getLocation() {
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
    
    // MARK: FirstValue
    var firstPaymentMethod: PaymentMethod?
    var firstTravelArray: [Travel]?
    var firstParticipantTupleArray: [(name: String, isOn: Bool)]?
    var firstPayDate: Date?
    var firstCountryExpression: String?
    var firstLocationExpression: String?
    var firstCountry: Int?
    var firstCurrency: Int?
    var firstVisiblePayAmount: String?
    var firstCategory: ExpenseInfoCategory?
    var firstVisibleInfo: String?
    
    // MARK: - combine
    
    var travelPublisher: AnyPublisher<Travel?, Never> {
        MainViewModel.shared.$chosenTravelInManualRecord
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    var travelStream: AnyCancellable?
    
    // MARK: - in-string property
    
    var payAmount: Double = -1 { // passive
        didSet {
            if payAmount == -1 || currency == -1 {
                payAmountInWon = -1
            } else {
                if let exchangeRate = exchangeHandler.getExchangeRateFromKRW(currencyCode: CurrencyInfoModel.shared.currencyResult[currency]?.isoCodeNm ?? "") {
                    payAmountInWon = payAmount * exchangeRate
                } else {
                    payAmountInWon = -1
                }
            }
        }
    }
    @Published var visiblePayAmount: String = "" {
        didSet {
            if isFirstAppear {
                firstVisiblePayAmount = visiblePayAmount
            } else {
                isSameData = updateIsSameDataState()
                updateAlertState()
            }
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
                payAmount = Double(visiblePayAmount) ?? -100
            }
        }
    }
    @Published var payAmountInWon: Double = -1 // passive

    var info: String? // passive
    @Published var visibleInfo: String = "" {
        didSet {
            if isFirstAppear {
                firstVisibleInfo = visibleInfo
            } else {
                isSameData = updateIsSameDataState()
                updateAlertState()
            }
            if visibleInfo == "" {
                info = nil
            } else {
                info = visibleInfo
            }
        }
    }
    
    @Published var category: ExpenseInfoCategory = .unknown {
        didSet {
            if isFirstAppear {
                firstCategory = category
            } else {
                isSameData = updateIsSameDataState()
                updateAlertState()
            }
        }
    }

    @Published var paymentMethod: PaymentMethod = .unknown {
        didSet {
            if isFirstAppear {
                firstPaymentMethod = paymentMethod
            } else {
                isSameData = updateIsSameDataState()
                updateAlertState()
            }
        }
    }
    
    // MARK: - not-in-string property
    
    @Published var travelArray: [Travel] = [] {
        didSet {
            if isFirstAppear {
                firstTravelArray = travelArray
            } else {
                isSameData = updateIsSameDataState()
                updateAlertState()
            }
        }
    }
    
    @Published var participantTupleArray: [(name: String, isOn: Bool)] = [("나", true)] {
        didSet {
            if isFirstAppear {
                firstParticipantTupleArray = participantTupleArray
            } else {
                isSameData = updateIsSameDataState()
                updateAlertState()
            }
        }
    } // passive

    @Published var payDate: Date = Date() {
        didSet {
            if isFirstAppear {
                firstPayDate = payDate
            } else {
                isSameData = updateIsSameDataState()
                updateAlertState()
            }
        }
    }
    
    var currentDate: Date = Date()

    @Published var country: Int = -1 {
        didSet {
            countryExpression = "\(CountryInfoModel.shared.countryResult[country]?.koreanNm ?? CountryInfoModel.shared.countryResult[-1]!.koreanNm)"
            locationExpression = ""

            if country == 3 { // 미국
                currencyCandidateArray = [4, 0] // 미국 달러, 한국 원
            } else {
                let stringCurrencyArray = CountryInfoModel.shared.countryResult[country]?.relatedCurrencyArray ?? []
                currencyCandidateArray = []
                for t in CurrencyInfoModel.shared.currencyResult where stringCurrencyArray.contains(t.value.isoCodeNm) {
                    currencyCandidateArray.append(t.key)
                }
                
                if !currencyCandidateArray.contains(4) { // 미국 달러
                    currencyCandidateArray.append(4)
                }
                if !currencyCandidateArray.contains(0) { // 한국 원
                    currencyCandidateArray.append(0)
                }
            }
            
            if currency == 4 && country != 3 { // 미국 달러, !미국
                return
            } else if currency == 0 && country != 0 { // 한국 원, !한국
                return
            } else {
                currency = currencyCandidateArray.first ?? 4
            }
        }
    }
    @Published var countryExpression: String = "" {
        didSet {
            if isFirstAppear {
                firstCountryExpression = countryExpression
            } else {
                isSameData = updateIsSameDataState()
                updateAlertState()
            }
        }
    } // passive
    
    @Published var locationExpression: String = "" {
        didSet {
            if isFirstAppear {
                firstLocationExpression = locationExpression
            } else {
                isSameData = updateIsSameDataState()
                updateAlertState()
            }
        }
    }
    
    var currentCountry: Int = -1
    var currentLocation: String = ""
    @Published var otherCountryCandidateArray: [Int] = [] // passive
    
    @Published var currency: Int = 3 {
        didSet {
            if isFirstAppear {
                firstCurrency = currency
            } else {
                isSameData = updateIsSameDataState()
                updateAlertState()
            }
            if payAmount == -1 || currency == -1 {
                payAmountInWon = -1
            } else {
                if let exchangeRate = exchangeHandler.getExchangeRateFromKRW(currencyCode: CurrencyInfoModel.shared.currencyResult[currency]?.isoCodeNm ?? "") {
                    payAmountInWon = payAmount * exchangeRate
                } else {
                    payAmountInWon = -1
                }
            }
        }
    }
    @Published var currencyCandidateArray: [Int] = []
    @Published var visibleNewNameOfParticipant: String = ""
    
    var soundRecordData: Data?
    
    // MARK: - view state
    
    @Published var wantToActivateAutoSaveTimer = false
    @Published var travelChoiceModalIsShown = false
    @Published var categoryChoiceModalIsShown = false
    @Published var countryChoiceModalIsShown = false
    @Published var dateChoiceModalIsShown = false
    @Published var backButtonAlertIsShown = false
    @Published var addingParticipant = false
    @Published var countryIsModified = false
    @Published var playingRecordSound = false
    @Published var isSameData = true {
        didSet {
            print("isSameData: \(isSameData)")
        }
    }
    @Published var showAlert = false {
        didSet {
            print("showAlert: \(showAlert)")
        }
    }
    @Published var isFirstAppear = true {
        didSet {
            print("isFirstAppear: \(isFirstAppear)")
        }
    }
    
    // MARK: - timer
    
    @Published var autoSaveTimer: Timer?
    @Published var secondCounter: Int?
    
    override init() {
        super.init()
        print("ManualRecordInExpenseViewModel | init")
        locationManager = CLLocationManager()
        locationManager?.delegate = locationManagerDelegate
        locationManagerDelegate.parent = self
        
        // MainViewModel의 chosenTravelInManualRecord가 변화할 때 자동으로 이루어질 일을 sink로 처리
        travelStream = travelPublisher.sink { chosenTravel in
            if let chosenTravel {
                if let participantArrayInChosenTravel = chosenTravel.participantArray {
                    self.participantTupleArray = [("나", true)] + participantArrayInChosenTravel.map { ($0, true) }
                } else {
                    self.participantTupleArray = [("나", true)]
                }
                var expenseArray: [Expense] = []
                do {
                    try expenseArray = self.viewContext.fetch(Expense.fetchRequest()).filter { expense in
                        if let belongTravel = expense.travel {
                            return belongTravel.id == chosenTravel.id
                        } else {
                            return false
                        }
                    }
                } catch {
                    print("error fetching expenses: \(error.localizedDescription)")
                }
                self.otherCountryCandidateArray = Array(Set(expenseArray.map { Int($0.country) })).sorted()
            } else {
                self.participantTupleArray = [("나", true)]
                self.otherCountryCandidateArray = []
            }
        }
    }
    
    deinit {
        stopPlayingAudio()
    }
        
    func save() {
        var expense: Expense?
        do {
            expense = try viewContext.fetch(Expense.fetchRequest()).filter { expense in
                return expense.id == expenseId
            }.first
        } catch let error {
            print("\(error.localizedDescription)")
        }
        guard let expense = expense else { return }
        
        expense.category = Int64(category.rawValue)
        expense.country = Int64(country)
        expense.currency = Int64(currency)
        let code = CurrencyInfoModel.shared.currencyResult[currency]?.isoCodeNm ?? "Unknown"
        expense.exchangeRate = exchangeHandler.getExchangeRateFromKRW(currencyCode: code) ?? -1
        expense.info = info
        expense.location = locationExpression
        expense.participantArray = participantTupleArray.filter { $0.1 == true }.map { $0.0 }
        expense.payAmount = payAmount
        expense.payDate = DateGapHandler.shared.convertBeforeSaving(date: payDate)
        expense.paymentMethod = Int64(paymentMethod.rawValue)
        
//        if let soundRecordData, let soundData = try? Data(contentsOf: soundRecordData) {
//            expense.voiceRecordFile = soundData
//        }
        expense.voiceRecordFile = soundRecordData
        
        if let chosenTravel = MainViewModel.shared.chosenTravelInManualRecord {
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
    
    // MARK: - voice
    
    var audioPlayer: AVAudioPlayer?
    
    func startPlayingAudio(url: URL) {
        
        let playSession = AVAudioSession.sharedInstance()
        
        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device")
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self //
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
        } catch {
            print("Playing Failed")
        }
    }
    
    func startPlayingAudio(data: Data) {
        let tempDirectoryURL = FileManager.default.temporaryDirectory
        let randomID = UUID().uuidString
        let fileURL = tempDirectoryURL.appendingPathComponent(randomID).appendingPathExtension("m4a")

        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save file: \(error)")
            return
        }

        let playSession = AVAudioSession.sharedInstance()

        do {
            try playSession.overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
        } catch {
            print("Playing failed in Device")
        }
        
        do {
            try playSession.setCategory(.playback)
            try playSession.setActive(true)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Playing Failed")
        }
    }
    
    func stopPlayingAudio() {
        audioPlayer?.stop()
    }
    
    func deleteUselessAudioFiles() {
        let soundRecordPath: URL? = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // VOICE로 시작하는 파일 삭제
        if let soundRecordPath {
            do {
                let fileManager = FileManager.default
                let filesInDirectory = try fileManager.contentsOfDirectory(at: soundRecordPath, includingPropertiesForKeys: nil)
                for fileURL in filesInDirectory where fileURL.lastPathComponent.hasPrefix("VOICE") {
                    try fileManager.removeItem(at: fileURL)
                }
            } catch {
                print("error deleting sound files: \(error.localizedDescription)")
            }
        }
    }
    
    func updateAlertState() {
        showAlert = self.backButtonAlertIsShown && !self.isSameData
    }
    
    func updateIsSameDataState() -> Bool {
        if let firstCountry = self.firstCountry,
           let firstCategory = self.firstCategory,
           let firstCurrency = self.firstCurrency,
           let firstPayDate = self.firstPayDate,
           let firstTravelArray = self.firstTravelArray,
           let firstVisibleInfo = self.firstVisibleInfo,
           let firstPaymentMethod = self.firstPaymentMethod,
           let firstCountryExpression = self.firstCountryExpression,
           let firstLocationExpression = self.firstLocationExpression,
           let firstVisiblePayAmount = self.firstVisiblePayAmount,
           let firstParticipantTupleArray = self.firstParticipantTupleArray
        {
            return (firstCountry == country) &&
                   (firstCategory == category) &&
                   (firstCurrency == currency) &&
                   (firstPayDate == payDate) &&
                   (firstTravelArray == travelArray) &&
                   (firstVisibleInfo == visibleInfo) &&
                   (firstPaymentMethod == paymentMethod) &&
                   (firstCountryExpression == countryExpression) &&
                   (firstLocationExpression == locationExpression) &&
                   (firstVisiblePayAmount == visiblePayAmount) &&
                   (zip(firstParticipantTupleArray, participantTupleArray).allSatisfy { $0 == $1 })
        }
        print("updateIsSameDataState | updateIsSameDataState | updateIsSameDataState: false")
        return false
    }
    
    func checkFirstAppear() {
        print("checkFirstAppear")
        if isFirstAppear {
            isFirstAppear = false
        }
    }
}

extension ManualRecordInExpenseViewModel: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            if flag {
                // 재생이 성공적으로 끝났을 때 실행할 코드
                playingRecordSound = false
            } else {
                // 재생이 실패했을 때 실행할 코드
                print("Failed to play recorded sound.")
            }
        }
}
