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
}
