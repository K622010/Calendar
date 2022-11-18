//
//  Persistence.swift
//  CoreDataExample
//
//  Created by 江越瑠一 on 2022/10/07.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for index in 0..<2 {
            let newClassIndex = ClassIndex(context: viewContext)
            newClassIndex.subject = "英語"
            newClassIndex.place = ""
            newClassIndex.startTime = Date()
            newClassIndex.endTime = Date()
            newClassIndex.red = 255
            newClassIndex.blue = 0
            newClassIndex.green = 0
            newClassIndex.color = "06C7AC"
            newClassIndex.attend = 0
            newClassIndex.absent = 0
            newClassIndex.late = 0
        }
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
        container = NSPersistentContainer(name: "Calendar")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
