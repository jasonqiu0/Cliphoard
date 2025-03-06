//
//  ClipboardEntry+CoreDataProperties.swift
//  Cliphoard
//
//  Created by Jason Qiu on 3/4/25.
//
//

import Foundation
import CoreData


extension ClipboardEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipboardEntry> {
        return NSFetchRequest<ClipboardEntry>(entityName: "ClipboardEntry")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var hiddenText: String?
    @NSManaged public var dateAdded: Date?
    
    var wrappedID: UUID { id ?? UUID() }
    var wrappedTitle: String { title?.isEmpty == false ? title! : hiddenText ?? "" }
    var wrappedHiddenText: String { hiddenText ?? "" }
    var wrappedDateAdded: Date { dateAdded ?? Date() }
}

extension ClipboardEntry : Identifiable {

}
