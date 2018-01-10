//
//  SynonymTags+CoreDataProperties.swift
//  Synonymes
//
//  Created by  Shadow on 09.01.18.
//  Copyright © 2018  Shadow. All rights reserved.
//
//

import Foundation
import CoreData


extension SynonymTags {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SynonymTags> {
        return NSFetchRequest<SynonymTags>(entityName: "SynonymTags")
    }

    @NSManaged public var idOfPopular: Int32
    @NSManaged public var idSynonym: Int32
    @NSManaged public var synonymName: String?
    @NSManaged public var popular: PopularTags?

}
