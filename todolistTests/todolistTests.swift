//
//  todolistTests.swift
//  todolistTests
//
//  Created by 黃皓澤 on 2025/5/28.
//

import Testing
import CoreData
@testable import todolist // Import your app module

struct todolistTests {

    // Helper to get a fresh in-memory persistence controller and context for each test
    // This ensures test isolation.
    func createTestableContext() -> (PersistenceController, NSManagedObjectContext) {
        let persistenceController = PersistenceController(inMemory: true)
        return (persistenceController, persistenceController.container.viewContext)
    }

    @Test("TodoItem Creation") func testCreateTodoItem() throws {
        let (pc, viewContext) = createTestableContext()

        let taskDesc = "Test Task"
        let dueDate = Date()
        let id = UUID()

        let newItem = TodoItem(context: viewContext)
        newItem.id = id
        newItem.taskDescription = taskDesc
        newItem.dueDate = dueDate
        // isCompleted is false by default (optional="NO" defaultValueString="NO" usesScalarValueType="YES")
        // completedDate is nil by default

        #expect(newItem.id == id)
        #expect(newItem.taskDescription == taskDesc)
        #expect(newItem.dueDate == dueDate)
        #expect(newItem.isCompleted == false)
        #expect(newItem.completedDate == nil)

        do {
            try viewContext.save()
        } catch {
            Issue.record("Failed to save context: \(error)")
            throw error
        }

        // Fetch to ensure it's saved
        let fetchRequest: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            #expect(results.count == 1)
            if let fetchedItem = results.first {
                #expect(fetchedItem.taskDescription == taskDesc)
            } else {
                Issue.record("Fetched item was nil")
            }
        } catch {
            Issue.record("Failed to fetch created item: \(error)")
            throw error
        }
    }

    @Test("Mark TodoItem Complete") func testMarkTodoItemComplete() throws {
        let (pc, viewContext) = createTestableContext()
        let id = UUID()

        let newItem = TodoItem(context: viewContext)
        newItem.id = id
        newItem.taskDescription = "Task to complete"
        newItem.dueDate = Date()
        
        // Mark as complete
        newItem.isCompleted = true
        let completionDate = Date()
        newItem.completedDate = completionDate

        #expect(newItem.isCompleted == true)
        #expect(newItem.completedDate == completionDate)

        do {
            try viewContext.save()
        } catch {
            Issue.record("Failed to save context: \(error)")
            throw error
        }
        
        // Fetch and verify
        let fetchRequest: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            #expect(results.count == 1)
            if let fetchedItem = results.first {
                #expect(fetchedItem.isCompleted == true)
                #expect(fetchedItem.completedDate == completionDate)
            } else {
                Issue.record("Fetched item was nil")
            }
        } catch {
            Issue.record("Failed to fetch or unwrap completed item: \(error)")
            throw error
        }
    }

    @Test("Edit TodoItem") func testEditTodoItem() throws {
        let (pc, viewContext) = createTestableContext()
        let id = UUID()
        let initialDesc = "Initial Description"
        let initialDueDate = Date()
        
        let item = TodoItem(context: viewContext)
        item.id = id
        item.taskDescription = initialDesc
        item.dueDate = initialDueDate
        
        try viewContext.save()

        // Edit properties
        let updatedDesc = "Updated Description"
        let updatedDueDate = Calendar.current.date(byAdding: .day, value: 1, to: initialDueDate)!
        
        item.taskDescription = updatedDesc
        item.dueDate = updatedDueDate
        
        try viewContext.save()

        // Fetch and verify
        let fetchRequest: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            #expect(results.count == 1)
            if let fetchedItem = results.first {
                #expect(fetchedItem.taskDescription == updatedDesc)
                #expect(fetchedItem.dueDate == updatedDueDate)
            } else {
                Issue.record("Fetched item was nil")
            }
        } catch {
            Issue.record("Failed to fetch or unwrap edited item: \(error)")
            throw error
        }
    }

    @Test("Delete TodoItem") func testDeleteTodoItem() throws {
        let (pc, viewContext) = createTestableContext()
        let itemId = UUID()
        
        let item = TodoItem(context: viewContext)
        item.id = itemId
        item.taskDescription = "Task to delete"
        item.dueDate = Date()
        
        try viewContext.save()

        // Delete the item
        viewContext.delete(item)
        try viewContext.save()

        // Attempt to fetch and verify it's gone
        let fetchRequest: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", itemId as CVarArg)
        
        do {
            let results = try viewContext.fetch(fetchRequest)
            #expect(results.count == 0)
        } catch {
            // This error block might not be reached if fetch simply returns empty.
            // The expectation #expect(results.count == 0) handles the success case.
            Issue.record("Error fetching after deletion (should be empty): \(error)")
            throw error
        }
    }
}
