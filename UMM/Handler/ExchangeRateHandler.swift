//
//  ExchangeRateHandler.swift
//  UMM
//
//  Created by 김태현 on 10/30/23.
//

import Foundation

struct ExchangeRate: Codable {
    let base_code: String
    let conversion_rates: [String: Double]
    let time_last_update_utc: String
    let time_last_update_unix: Int
}

class ExchangeRateHandler {
    
    static let shared = ExchangeRateHandler()
    
    private init() {}
    
    func fetchAndSaveExchangeRates() {
        guard let apiKey = Bundle.main.infoDictionary?["API_KEY"] as? String else { return }
        let baseCode = "KRW"
        guard let url = URL(string: "https://v6.exchangerate-api.com/v6/\(apiKey)/latest/\(baseCode)") else { return }
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print("Failed to fetch data from URL: \(error)")
                return
            }
            guard let data = data else {
                print("No data returned from URL")
                return
            }
            do {
                let decodedResponse = try JSONDecoder().decode(ExchangeRate.self, from: data)
                DispatchQueue.main.async {
                    if let encodedData = try? JSONEncoder().encode(decodedResponse) {
                        UserDefaults.standard.set(encodedData, forKey: "SavedExchangeRates")
                    }
                }
            } catch {
                print("Failed to decode data: \(error)")
            }
        }.resume()
    }
    
    func loadExchangeRatesFromUserDefaults() -> ExchangeRate? {
        guard let savedData = UserDefaults.standard.data(forKey: "SavedExchangeRates") else {
            print("No data found in UserDefaults")
            return nil
        }
        do {
            return try JSONDecoder().decode(ExchangeRate.self, from: savedData)
        } catch let error {
            print("Could not load. \(error)")
            return nil
        }
    }
    
    func getExchangeRateFromKRW(currencyCode: String) -> Double? {
        guard let loadedData = loadExchangeRatesFromUserDefaults(),
              let rate = loadedData.conversion_rates[currencyCode.uppercased()] else {
            return nil
        }
        return 1 / rate
    }
    
    func isSameDate(_ dateInt: Int?) -> Bool {
        guard let dateInt = dateInt else { return false }
        let date = Date(timeIntervalSince1970: TimeInterval(dateInt))
        let calendar = Calendar.current
        let componentsToday = calendar.dateComponents([.year, .month, .day], from: Date())
        let componentsDate = calendar.dateComponents([.year, .month, .day], from: date)
                
        return componentsToday == componentsDate
    }
}
