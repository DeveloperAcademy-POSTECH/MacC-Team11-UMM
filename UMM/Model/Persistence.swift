//
//  Persistence.swift
//  UMM
//
//  Created by Wonil Lee on 10/10/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        // Dummy data will go here later
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    let container: NSPersistentContainer
      init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "UMM")
        if inMemory {
          // swiftlint:disable:next force_unwrapping
          container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
          if let error = error as NSError? {
            fatalError("Unresolved error \(error), \(error.userInfo)")
          }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.name = "viewContext"
        /// - Tag: viewContextMergePolicy
        container.viewContext.mergePolicy =
        NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
      }
    
    func deleteItems(object: Travel?) {

        var travelToBeDeleted: Travel?
        do {
            travelToBeDeleted = try self.container.viewContext.fetch(Travel.fetchRequest()).filter { travel in
                if let object {
                    return object.id == travel.id
                }
                return false
            }.first
        } catch {
            print("error fetching travel: \(error.localizedDescription)")
        }
        
        if travelToBeDeleted != nil {
            self.container.viewContext.delete(travelToBeDeleted!)
        }

        try? self.container.viewContext.save()
    }
    
    func deleteExpenseFromTravel(travel: Travel?, expenseId: ObjectIdentifier) {
        guard let travel = travel,
              let expenses = travel.expenseArray as? Set<Expense>,
              let expenseToDelete = expenses.first(where: { $0.id == expenseId }) else { return }

        do {
            let object = try self.container.viewContext.existingObject(with: expenseToDelete.objectID)
            self.container.viewContext.delete(object)
            try self.container.viewContext.save()
            
        } catch {
            let nsError = error as NSError
            print("error while deleteExpenseFromTravel: \(nsError.localizedDescription)")
        }
    }
}

extension PersistenceController {
    func exportDataToCSV(travel: Travel) {
        let expenses = travel.expenseArray as? Set<Expense>
        let sortedExpenses = expenses?.sorted(by: { $0.payDate ?? Date.distantFuture < $1.payDate ?? Date.distantPast })

        var csvPage1: String = "제목,원화 환산 금액,현지 금액,환율,결제 수단,카테고리,결제 인원,결제 위치,소비 시각\n"
        for expense in sortedExpenses ?? [] {
            let info = expense.info ?? "-"
            let payAmountWithCurrency = String(format: "%.0f", expense.payAmount) + (CurrencyInfoModel.shared.currencyResult[Int(expense.currency)]?.symbol ?? "-")
            
            let exchangeRate = expense.exchangeRate
            let exchangeRateString = String(format: "%.2f", exchangeRate)
            
            let payAmountInWon = expense.payAmount * expense.exchangeRate
            let payAmountInWonString = String(format: "%.0f", payAmountInWon)

            let payDate = expense.payDate?.toString(dateFormat: "yy.MM.dd(E) HH:mm") ?? Date.distantPast.toString(dateFormat: "yy.MM.dd(E) HH:mm")
            let paymentMethod = PaymentMethod.titleFor(rawValue: Int(expense.paymentMethod))
            let category = ExpenseInfoCategory.descriptionFor(rawValue: Int(expense.category))
            let participantString = "\"\(expense.participantArray?.joined(separator: ", ") ?? "")\""
            let countryAndLocatoinExpression = (CountryInfoModel.shared.countryResult[Int(expense.country)]?.koreanNm ?? "") + " " + (expense.location ?? "")

            let row = "\(info),\(payAmountInWonString),\(payAmountWithCurrency),\(exchangeRateString),\(paymentMethod),\(category),\(participantString),\(countryAndLocatoinExpression),\(payDate)\n"
            csvPage1.append(row)
        }

        var csvPage2: String = "이름,금액 합계\n"
        if let participants = travel.participantArray {
            let participantsWithMe = ["나"] + participants
            let totalSum = participantsWithMe.reduce(0.0) { sum, participant in
                let expenses = sortedExpenses?.filter { $0.participantArray?.contains(participant) ?? false }
                let totalExpense = expenses?.reduce(0, { (currentSum, expense) -> Double in
                    let participantCount = Double(expense.participantArray?.count ?? 1)
                    let dividedExpense = (expense.payAmount * expense.exchangeRate) / participantCount
                    return currentSum + dividedExpense
                }) ?? 0
                let totalExpenseString = String(format: "%.0f", totalExpense)

                let participantArray = expenses?.first?.participantArray ?? []
                let participantString = "\"\(participantArray.joined(separator: ", "))\""

                let row = "\(participant),\(totalExpenseString),\(participantString)\n"
                csvPage2.append(row)

                return sum + totalExpense
            }

            let totalSumString = String(format: "%.0f", totalSum)
            csvPage2.append("총합,\(totalSumString),\n")
        }

        let csvDataPage1 = csvPage1.data(using: .utf8)
        let csvDataPage2 = csvPage2.data(using: .utf8)
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURLPage1 = documentsDirectory.appendingPathComponent("모든소비내역_\(Date().toString(dateFormat: "yy.MM.dd")).csv")
        let fileURLPage2 = documentsDirectory.appendingPathComponent("정산내역_\(Date().toString(dateFormat: "yy.MM.dd")).csv")

        do {
            try csvDataPage1?.write(to: fileURLPage1, options: .atomic)
            try csvDataPage2?.write(to: fileURLPage2, options: .atomic)
            print("CSV files have been saved at \(fileURLPage1) and \(fileURLPage2)")
        } catch {
            print("Failed to write data to CSV: \(error)")
        }
    }
}

