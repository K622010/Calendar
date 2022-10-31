//
//  ClassIndex+CoreDataProperties.swift
//  Calendar
//
//  Created by 江越瑠一 on 2022/10/24.
//
//

import Foundation
import CoreData


extension ClassIndex {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClassIndex> {
        return NSFetchRequest<ClassIndex>(entityName: "ClassIndex")
    }

    @NSManaged public var red: Int16
    @NSManaged public var blue: Int16
    @NSManaged public var green: Int16
    @NSManaged public var color: String?
    @NSManaged public var attend: Int16
    @NSManaged public var late: Int16
    @NSManaged public var absent: Int16
    @NSManaged public var subject: String?
    @NSManaged public var place: String?
    @NSManaged public var startTime: Date?
    @NSManaged public var endTime: Date?
    @NSManaged public var date: Date?

}

extension ClassIndex : Identifiable {

}
