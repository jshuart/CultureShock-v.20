//
//  Class.swift
//  CultureShock
//
//  Created by Joe Shuart on 8/19/15.
//  Copyright (c) 2015 Joe Shuart. All rights reserved.
//

import Foundation
import CoreData

@objc(Class)

class Class: NSManagedObject {

    @NSManaged var field_ages_value: String?
    @NSManaged var field_class_day_value: String
    @NSManaged var class_time_final: String
    @NSManaged var field_class_flex_header_value: String
    @NSManaged var title_final: String
    @NSManaged var field_class_footer_value: String?
    @NSManaged var field_class_flex_footer_value: String?
    @NSManaged var field_class_instructor_nid: String?
    @NSManaged var index: NSNumber

}
