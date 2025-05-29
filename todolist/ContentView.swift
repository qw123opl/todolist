//
//  ContentView.swift
//  todolist
//
//  Created by 黃皓澤 on 2025/5/28.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TodoItem.dueDate, ascending: true)],
        predicate: NSPredicate(format: "isCompleted == %@", NSNumber(value: false)),
        animation: .default)
    private var items: FetchedResults<TodoItem>

    @State private var newTaskDescription: String = ""
    @State private var newDueDate: Date = Date()

    // State for managing the edit sheet
    @State private var isShowingEditSheet: Bool = false
    @State private var editingItem: TodoItem? = nil
    @State private var editableTaskDescription: String = ""
    @State private var editableDueDate: Date = Date()

    // State to manage selected tab
    @State private var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: Active Tasks (Original ContentView layout)
            NavigationView {
                VStack {
                    List {
                        ForEach(items) { item in
                            HStack {
                            VStack(alignment: .leading) {
                                Text(item.taskDescription ?? "Untitled Task")
                                    .font(.headline)
                                Text("Due: \(item.dueDate ?? Date(), formatter: itemFormatter)")
                                    .font(.subheadline)
                            }
                            Spacer() // Pushes the circle to the right
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(item.isCompleted ? .green : .gray)
                                .onTapGesture {
                                    toggleComplete(item: item)
                                }
                        }
                        .contextMenu { // Add context menu for editing
                            Button {
                                editingItem = item
                                editableTaskDescription = item.taskDescription ?? ""
                                editableDueDate = item.dueDate ?? Date()
                                isShowingEditSheet = true
                            } label: {
                                Label("Edit Item", systemImage: "pencil")
                            }
                        }
                    }
                        .onDelete(perform: deleteItems)
                    }
                    .navigationTitle("Todolist 首頁") // Updated title for the first tab
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            EditButton()
                        }
                        // Potentially add a ToolbarItem for adding new items if the bottom bar is removed/changed
                    }

                    // Input area for new tasks
                    HStack {
                        TextField("New task description", text: $newTaskDescription)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        DatePicker("", selection: $newDueDate, displayedComponents: .date)
                        Button(action: addItem) {
                            Label("Add Item", systemImage: "plus.circle.fill")
                                .labelStyle(.iconOnly)
                        }
                    }
                    .padding()
                }
                .sheet(isPresented: $isShowingEditSheet) {
                    editSheetView // This sheet will be presented from the context of the NavigationView
                }
            }
            .tabItem {
                Label("待辦", systemImage: "list.bullet") // Updated Label
            }
            .tag(0)

            // Tab 2: Calendar
            CalendarView() // CalendarView already has its own NavigationView if needed for its title
                .tabItem {
                    Label("日曆", systemImage: "calendar") // Updated Label
                }
                .tag(1)

            // Tab 3: History
            HistoryView() // HistoryView already has its own NavigationView
                .tabItem {
                    Label("紀錄", systemImage: "clock.fill") // Updated Label
                }
                .tag(2)
        }
        // The .environment for managedObjectContext is already provided by todolistApp.swift
        // to the entire ContentView, so all tabs will inherit it.
    }
    
    // editSheetView, saveEditedItem, toggleComplete, addItem, deleteItems remain the same
    // as they are part of the "Active Tasks" tab's functionality.

    private var editSheetView: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Todo Item")) {
                    TextField("Task Description", text: $editableTaskDescription)
                    DatePicker("Due Date", selection: $editableDueDate, displayedComponents: .date)
                }

                Section {
                    Button("Save Changes") {
                        saveEditedItem()
                        isShowingEditSheet = false
                    }
                    Button("Cancel") {
                        isShowingEditSheet = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isShowingEditSheet = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEditedItem()
                        isShowingEditSheet = false
                    }
                }
            }
        }
    }

    private func saveEditedItem() {
        guard let itemToEdit = editingItem else { return }

        itemToEdit.taskDescription = editableTaskDescription
        itemToEdit.dueDate = editableDueDate
        // itemToEdit.isCompleted and itemToEdit.completedDate are not changed here

        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func toggleComplete(item: TodoItem) {
        withAnimation {
            item.isCompleted = true
            item.completedDate = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func addItem() {
        withAnimation {
            if newTaskDescription.isEmpty { return } // Do not add empty tasks
            let newItem = TodoItem(context: viewContext)
            newItem.id = UUID()
            newItem.taskDescription = newTaskDescription
            newItem.dueDate = newDueDate
            newItem.isCompleted = false
            newItem.completedDate = nil // Ensure completedDate is nil for new tasks

            do {
                try viewContext.save()
                newTaskDescription = "" // Reset input field
                newDueDate = Date() // Reset date picker
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium // Changed from .short to .medium
    formatter.timeStyle = .none
    return formatter
}()

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
