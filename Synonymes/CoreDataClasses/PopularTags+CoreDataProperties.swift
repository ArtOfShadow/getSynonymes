//
//  PopularTags+CoreDataProperties.swift
//  Synonymes
//
//  Created by  Shadow on 09.01.18.
//  Copyright © 2018  Shadow. All rights reserved.
//
//

import Foundation
import CoreData


extension PopularTags {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PopularTags> {
        return NSFetchRequest<PopularTags>(entityName: "PopularTags")
    }

    @NSManaged public var idPopular: Int32
    @NSManaged public var popularName: String?
    @NSManaged public var synonyms: NSSet?

}

// MARK: Generated accessors for synonyms
extension PopularTags {

    @objc(addSynonymsObject:)
    @NSManaged public func addToSynonyms(_ value: SynonymTags)

    @objc(removeSynonymsObject:)
    @NSManaged public func removeFromSynonyms(_ value: SynonymTags)

    @objc(addSynonyms:)
    @NSManaged public func addToSynonyms(_ values: NSSet)

    @objc(removeSynonyms:)
    @NSManaged public func removeFromSynonyms(_ values: NSSet)

}
