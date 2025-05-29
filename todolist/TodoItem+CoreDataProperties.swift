//
//  TodoItem+CoreDataProperties.swift
//  todolist
//
//  Created by Todolist Agent on 2023-10-27.
//  This file was automatically generated and should not be edited.
//
import Foundation
import CoreData

extension TodoItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoItem> {
        return NSFetchRequest<TodoItem>(entityName: "TodoItem")
    }

    @NSManaged public var completedDate: Date?
    @NSManaged public var dueDate: Date // Corrected: Non-optional
    @NSManaged public var id: UUID      // Corrected: Non-optional
    @NSManaged public var isCompleted: Bool
    @NSManaged public var taskDescription: String // Corrected: Non-optional

}

extension TodoItem : Identifiable {

}
