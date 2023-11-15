//
//  ManualRecordViewModel.swift
//  UMM
//
//  Created by Wonil Lee on 10/21/23.
//

import AVFoundation
import Combine
import CoreLocation

final class ManualRecordViewModel: NSObject, ObservableObject {
    
    let viewContext = PersistenceController.shared.container.viewContext
    let exchangeHandler = ExchangeRateHandler.shared
    
    // MARK: - 위치 정보
    
    var location: CLLocation?
    
    func getLocation(completion: @escaping () -> Void) {
        location = DateGapHandler.shared.currentLocation
        if let location {
            CLGeocoder().reverseGeocodeLocation(location) { placemarks, _  in
                if let newPlacemark = placemarks?.first {
                    let code = newPlacemark.isoCountryCode ?? ""
                    let countryKey = CountryInfoModel.shared.countryResult.filter { tuple in
                        let pairCode = tuple.value.locationNm.components(separatedBy: "-")
                        if pairCode.count == 2 {
                            return pairCode[1] == code
                        } else {
                            return false
                        }
                    }.first?.key ?? -1
                    self.currentCountry = countryKey
                    self.currentLocation = "\(newPlacemark.locality ?? "")"
                }
                completion()
            }
        }
    }
    
    // MARK: - 화폐
    
    func setInitialCurrency() {
        let stringCurrencyArray = CountryInfoModel.shared.countryResult[country]?.relatedCurrencyArray ?? []
        var tempCurrencyCandidateArray: [Int] = []
        for t in CurrencyInfoModel.shared.currencyResult where stringCurrencyArray.contains(t.value.isoCodeNm) {
            tempCurrencyCandidateArray.append(t.key)
        }
        
        if !tempCurrencyCandidateArray.contains(4) { // 미국 달러
            tempCurrencyCandidateArray.append(4)
        }
        if !tempCurrencyCandidateArray.contains(0) { // 한국 원
            tempCurrencyCandidateArray.append(0)
        }
        
        currency = tempCurrencyCandidateArray.first ?? 4
    }
    
    
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
            guard visiblePayAmount != "" else {
                payAmount = -1
                return
            }
            
            var tempVisiblePayAmount = visiblePayAmount.filter { [.arabicNumeric, .arabicDot].contains($0.getCharacterForm()) }
            if let dotIndex = tempVisiblePayAmount.firstIndex(of: ".") {
                if let twoMovesIndex = tempVisiblePayAmount.index(dotIndex, offsetBy: 3, limitedBy: tempVisiblePayAmount.endIndex) {
                    tempVisiblePayAmount = String(tempVisiblePayAmount[..<twoMovesIndex])
                }
                
            }

            var tempPayAmount = Double(tempVisiblePayAmount) ?? -1 // 음수 걸러내기
            if tempPayAmount < 0 {
                visiblePayAmount = "" // didSet is called again
                return
            } else if tempPayAmount > 1_000_000_000.99 { // 10억.99 초과 걸러내기; 소숫점 이하 2자리 정보 보존
                tempPayAmount = 1_000_000_000.0 + (tempPayAmount - floor(tempPayAmount))
                if abs(tempPayAmount - floor(tempPayAmount)) < 0.0000001 {
                    visiblePayAmount = String(format: "%.0f", tempPayAmount) // didSet is called again
                } else {
                    visiblePayAmount = String(tempPayAmount) // didSet is called again
                }
                return
            }
            
            if visiblePayAmount != tempVisiblePayAmount {
                visiblePayAmount = tempVisiblePayAmount
            }
            payAmount = tempPayAmount
        }
    }
    @Published var payAmountInWon: Double = -1 // passive

    var info: String? // passive
    @Published var visibleInfo: String = "" {
        didSet {
            guard visibleInfo != "" else {
                info = nil
                return
            }
            
            var weightedLength: Double = 0
            var tempVisibleInfo: String = ""
            
            for letter in visibleInfo {
                tempVisibleInfo.append(String(letter))
                if let safeScalar = Unicode.Scalar(String(letter)) {
                    let n = Int(safeScalar.value)
                    if (48 <= n && n <= 57) || (65 <= n && n <= 90) || (97 <= n && n <= 122) || (n == 32) || (n == 46) { // 0 ~ 9, A ~ Z, a ~ z, 공백, 마침표
                        weightedLength += 0.75
                    } else {
                        weightedLength += 1
                    }
                    if weightedLength <= 15 {
                        continue
                    } else {
                        tempVisibleInfo.removeLast()
                        break
                    }
                }
            }
            if visibleInfo != tempVisibleInfo {
                visibleInfo = tempVisibleInfo.reduce("") { $0 + String($1)} // didSet is called again
                return
            }
            
            info = visibleInfo
        }
    }
    
    @Published var category: ExpenseInfoCategory = .unknown
    @Published var paymentMethod: PaymentMethod = .unknown
    
    // MARK: - not-in-string property
    
    @Published var travelArray: [Travel] = []
    
    @Published var participantTupleArray: [(name: String, isOn: Bool)] = [("나", true)] // passive
    
    @Published var payDate: Date = Date()
    var currentDate: Date = Date()

    @Published var country: Int = -1 {
        didSet {
            countryExpression = "\(CountryInfoModel.shared.countryResult[country]?.koreanNm ?? CountryInfoModel.shared.countryResult[-1]!.koreanNm)"

            if country == 3 { // 미국
                currencyCandidateArray = [4, 0] // 미국 달러, 한국 원
            } else {
                let stringCurrencyArray = CountryInfoModel.shared.countryResult[country]?.relatedCurrencyArray ?? []
                var tempCurrencyCandidateArray: [Int] = []
                for t in CurrencyInfoModel.shared.currencyResult where stringCurrencyArray.contains(t.value.isoCodeNm) {
                    tempCurrencyCandidateArray.append(t.key)
                }
                
                if !tempCurrencyCandidateArray.contains(4) { // 미국 달러
                    tempCurrencyCandidateArray.append(4)
                }
                if !tempCurrencyCandidateArray.contains(0) { // 한국 원
                    tempCurrencyCandidateArray.append(0)
                }
                
                currencyCandidateArray = tempCurrencyCandidateArray
            }
            
            currency = currencyCandidateArray.first ?? 4
        }
    }
    @Published var countryExpression: String = "" // passive
    @Published var locationExpression: String = ""

    var currentCountry: Int = -1 {
        didSet {
            country = currentCountry
            
            if !otherCountryCandidateArray.contains(currentCountry) {
                otherCountryCandidateArray.append(currentCountry)
            }
        }
    }
    var currentLocation: String = "" {
        didSet {
            locationExpression = currentLocation
        }
    }
    var otherCountryCandidateArray: [Int] = [] // passive
    
    @Published var currency: Int = 4 {
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
    var currencyCandidateArray: [Int] = [4]
    
    var soundRecordFileName: URL?
    
    // MARK: - view state
    
    @Published var wantToActivateAutoSaveTimer = false
    @Published var travelChoiceModalIsShown = false
    @Published var categoryChoiceModalIsShown = false
    @Published var countryChoiceModalIsShown = false
    @Published var dateChoiceModalIsShown = false
    @Published var backButtonAlertIsShown = false
    @Published var addingParticipant = false
    @Published var countryIsModified = false {
        didSet {
            if countryIsModified {
                locationExpression = ""
            }
        }
    }
    @Published var playingRecordSound = false
    @Published var savingIsDone = false
    
    // MARK: - timer
    
    var autoSaveTimer: Timer?
    @Published var afterSavingTimer: Timer?
    @Published var secondCounter: Int?
    
    override init() {
        super.init()
        print("ManualRecordViewModel | init")
        
        // MainViewModel의 chosenTravelInManualRecord가 변화할 때 자동으로 이루어질 일을 sink로 처리
        travelStream = travelPublisher.sink { chosenTravel in
            if let chosenTravel {
                if let participantArrayInChosenTravel = chosenTravel.participantArray {
                    self.participantTupleArray = [("나", true)] + participantArrayInChosenTravel.map { ($0, true) }
                } else {
                    self.participantTupleArray = [("나", true)]
                }
                var expenseArray: [Expense] = []
                if let expenseArrayOfChosenTravel = chosenTravel.expenseArray {
                    expenseArray = expenseArrayOfChosenTravel.allObjects as? [Expense] ?? []
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
        
        let expense = Expense(context: viewContext)
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
        
        if let soundRecordFileName, let soundData = try? Data(contentsOf: soundRecordFileName) {
            expense.voiceRecordFile = soundData
        }
        
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
    
    private var audioPlayer: AVAudioPlayer?
    
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
}

extension ManualRecordViewModel: AVAudioPlayerDelegate {
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
