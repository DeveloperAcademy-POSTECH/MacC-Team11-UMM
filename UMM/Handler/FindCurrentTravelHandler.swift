//
//  FindCurrentTravelHandler.swift
//  UMM
//
//  Created by 김태현 on 10/14/23.
//

// <-- travel의 초기값 -->
// 우선 순위: 오늘 Date의 포함 여부 > 최신 기록(travel.lastUpdate)
// 0. '여행 중' 여부는 Date 연산을 통해 결정된다.
    // a. 전체 여행 배열(dummyRecordViewModel.savedTravels)을 탐색한다
    // b. if startDate <= Date, if Date <= endDate || !endDate 조건을 만족하는 배열을 얻는다.
    // c. 반환되는 배열이 있다면 1을 진행한다. 없다면 2를 진행한다.
// 1. 여행 중:
    // a-1. 여행 중(종료일이 정해진): 가장 '최신 기록'의 travel과 연결한다.
    // a-2. 여행 중(종료일이 정해지지 않은): 가장 '최신 기록'의 travel과 연결한다.
        // ㄱ. 새로운 여행을 등록하면, "이미 진행 중인 여행을 종료할까요?" 묻는다.
        // ㄴ. 임시 저장을 시도할 경우, "이미 진행 중인 여행을 종료할까요?" 묻는다.
// 2. 여행 중이 아님:
    // 임시 저장 travel로 연결한다.
// <-- travel의 초기값 이후, 선택하는 경우 -->
// Picker로 사용자가 travel을 선택하는 경우에는, 선택한 travel에 저장을 해야 한다.

// 수정해야 할 것.
// travel에 lastUpdate(Date) attribute를 추가해야 한다.
// travel을 생성할 때, 시작일의 자정(00:00)으로 lastUpadte 변수 값을 초기화한다.
// travel을 생성할 때, 무기한 여행이라면, 종료일을 2099-12-31(Date) 값으로 저장한다.
// travel을 기록하고 저장할 때, lastUpdate를 현재 시각으로 업데이트 해준다.
// lastUpdate는 TodayExpenseView에서 지출 기록을 정렬할 때도 쓰인다.


import Foundation
import CoreData

class FindCurrentTravelHandler: ObservableObject {
    private let viewContext = PersistenceController.shared.container.viewContext
    private let dummyRecordViewModel = DummyRecordViewModel()
    @Published var currentTravel: Travel?
    
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: dateString)
    }
    
    func findCurrentTravel() {
        dummyRecordViewModel.fetchDummyTravel()
        let allTravels = dummyRecordViewModel.savedTravels
        let todayDate = Date()
        var currentTravels: [Travel] = []
        // 여행 중인 경우 여기에 해당하는 코드를 구현
        for travel in allTravels {
            if let startDate = convertStringToDate(travel.startDate ?? "2000-01-01"), let endDate = travel.endDate {
                if (startDate <= todayDate) && (todayDate <= endDate) {
                    currentTravels.append(travel)
                }
            }
        }
        // 여행 중
        if !currentTravels.isEmpty {
            currentTravels.sort { $0.lastUpdate ?? Date.distantPast > $1.lastUpdate ?? Date.distantPast }
            if let lastestTravel = currentTravels.first {
                self.currentTravel = lastestTravel
                print("여행 중: currentTravel: \(String(describing: currentTravel))")
                return
            }
        }
        // 여행 중이 아님
        print("여행 중X: currentTravel: \(String(describing: currentTravel))")
        return
    }
}
