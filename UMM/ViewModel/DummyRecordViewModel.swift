//
//    RecordViewModel.swift
//    UMM
//
//    Created by 김태현 on 10/17/23.
//
//  import Foundation
//  import CoreData
//
//  class DummyRecordViewModel: ObservableObject {
//      let viewContext = PersistenceController.shared.container.viewContext
//      @Published var savedTravels: [Travel] = []
//
//      // dummyData를 위한 프로퍼티
//      let dummyName = ["aaaa", "bbbb", "cccc", "dddd", "eeee", "ffff", "gggg", "hhhh", "iiii", "xxxx"]
//      let dummyStartDate = ["2023-01-09", "2023-02-25", "2023-04-08"]
//      let dummyEndDate = [
//              Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
//              Calendar.current.date(byAdding: .day, value: +1, to: Date())!,
//              Calendar.current.date(byAdding: .day, value: +2, to: Date())!,
//              Calendar.current.date(byAdding: .day, value: +3, to: Date())!
//
//          ]
//      let dummyLastUpdate = [
//              Calendar.current.date(byAdding: .day, value: +1, to: Date())!,
//              Calendar.current.date(byAdding: .day, value: +2, to: Date())!,
//              Calendar.current.date(byAdding: .day, value: +3, to: Date())!,
//              Calendar.current.date(byAdding: .day, value: +4, to: Date())!
//
//          ]
//  //    let dummyEndDate = ["2023-10-06", "2023-10-29", "2023-08-18"]
//
//      func fetchDummyTravel() {
//          let request = NSFetchRequest<Travel>(entityName: "Travel")
//          do {
//              savedTravels = try viewContext.fetch(request)
//          } catch let error {
//              print("Error during fetchDummyTravel: \(error.localizedDescription)")
//          }
//      }
//
//      func saveDummyTravel() {
//          do {
//              try viewContext.save()
//              fetchDummyTravel()
//          } catch let error {
//              print("Error while saveDummyTravel: \(error.localizedDescription)")
//          }
//      }
//
//      // dummy Travel을 추가하는 함수
//      func addDummyTravel() {
//          let tempTravel = Travel(context: viewContext)
//          tempTravel.id = UUID()
//          tempTravel.name = dummyName.randomElement()
//          tempTravel.startDate = dummyEndDate.randomElement()
//          tempTravel.endDate = dummyEndDate.randomElement()
//          tempTravel.lastUpdate = dummyLastUpdate.randomElement()
//
//          print("tempTravel.id: \(String(describing: tempTravel.id))")
//          print("tempTravel.name: \(tempTravel.name ?? "no name")")
//          print("tempTravel.startDate: \(String(describing: tempTravel.startDate))")
//          print("tempTravel.endDate: \(tempTravel.endDate ?? Date())")
//          print("tempTravel.lastUpdate: \(tempTravel.lastUpdate ?? Date())")
//          saveDummyTravel()
//      }
//  }
