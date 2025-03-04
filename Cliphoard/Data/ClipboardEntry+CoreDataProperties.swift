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
    
    var wrappedID: UUID { id ?? UUID() }  // Safer default
    var wrappedTitle: String { title?.isEmpty == false ? title! : hiddenText ?? "" }
    var wrappedHiddenText: String { hiddenText ?? "" }
}

extension ClipboardEntry : Identifiable {

}
