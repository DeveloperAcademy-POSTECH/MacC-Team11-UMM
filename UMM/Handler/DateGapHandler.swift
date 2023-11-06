//
//  DateGapHandler.swift
//  UMM
//
//  Created by Wonil Lee on 11/5/23.
//

import Foundation
import CoreLocation

final class LocationManagerDelegateForDateGapHandler: NSObject, CLLocationManagerDelegate {
    var parent: DateGapHandler?

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        parent?.currentLocation = locations.first
    }
}

final class DateGapHandler {
    static let shared = DateGapHandler()
    
    private init() {
        getLocation()
        let baseCoordinate = CLLocationCoordinate2D(latitude: 37.56, longitude: 127.00) // 서울 (latitude: 37.56, longitude: 127.00)
        // CLGeocoder를 사용하여 위치 정보를 가져온다.
        let geocoder = CLGeocoder()
        let nowDate = Date()
        
        geocoder.reverseGeocodeLocation(CLLocation(latitude: baseCoordinate.latitude, longitude: baseCoordinate.longitude)) { (placemarks, _) in
            if let basePlacemark = placemarks?.first {
                if let currentLocation = self.currentLocation {
                    geocoder.reverseGeocodeLocation(currentLocation) { (placemarks, _) in
                        if let currentPlacemark = placemarks?.first {
                            // 현재 위치와 목표 위치의 TimeZone을 가져온다.
                            if let baseTimeZone = basePlacemark.timeZone, let currentTimeZone = currentPlacemark.timeZone {
                                self.timeDifferenceInterval = TimeInterval(currentTimeZone.secondsFromGMT(for: nowDate) - baseTimeZone.secondsFromGMT(for: nowDate))
                            } else {
                                print("DateGapHandler | Failed to fetch time zones.")
                            }
                        } else {
                            print("DateGapHandler | Failed to fetch current placemark.")
                        }
                    }
                }
            } else {
                print("DateGapHandler | Failed to fetch base placemark.")
            }
        }
    }
    
    private var locationManager: CLLocationManager?
    private var locationManagerDelegate = LocationManagerDelegateForDateGapHandler()
    var currentLocation: CLLocation?
    var timeDifferenceInterval: TimeInterval = 0
    
    private func getLocation() {
        let locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        locationManager.delegate = locationManagerDelegate
        locationManagerDelegate.parent = self

        // locationManager(_:didUpdateLocations:) 메서드가 호출될 때까지 기다림.
        while currentLocation == nil {
            RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.1))
        }
    }
    
    func convertBeforeSaving(date: Date) -> Date {
        // base가 3시일 때 current가 5시이면 timeDifference는 7200. 저장하기 전에 date에 7200초를 더하면 base 기준 5시인 date가 된다.
        return date.addingTimeInterval(timeDifferenceInterval)
    }
    
    func convertBeforeShowing(date: Date) -> Date {
        // base가 3시일 때 current가 5시이면 timeDifference는 7200. 저장된 date가 base 기준 1시라고 하자. 이것은 current 기준 3시. 보여주기 전에 date에서 7200초를 빼면 current 기준 1시인 date가 된다.
        return date.addingTimeInterval(-timeDifferenceInterval)
    }
} 
