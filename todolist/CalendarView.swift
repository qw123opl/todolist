import SwiftUI
import CoreData

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var selectedDate: Date = Date()

    // 1. FetchRequest for TodoItems
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TodoItem.taskDescription, ascending: true)],
        animation: .default)
    private var items: FetchedResults<TodoItem>

    init() {
        // Initialize FetchRequest with predicate for the initial selectedDate
        // This is a common pattern: set up the initial predicate in init.
        // The _items is the property wrapper itself.
        _items = FetchRequest<TodoItem>(
            sortDescriptors: [NSSortDescriptor(keyPath: \TodoItem.taskDescription, ascending: true)],
            predicate: Self.predicateForDate(date: Date()), // Initial predicate for today
            animation: .default
        )
    }
    
    // Helper function to create predicate for a given date
    private static func predicateForDate(date: Date) -> NSPredicate {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        return NSPredicate(format: "dueDate >= %@ AND dueDate < %@", startDate as NSDate, endDate as NSDate)
    }

    var body: some View {
        VStack {
            DatePicker(
                "Select Date",
                selection: $selectedDate,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            .onChange(of: selectedDate) { newDate in
                // 2. Dynamic Predicate: Update FetchRequest's predicate when selectedDate changes
                items.nsPredicate = Self.predicateForDate(date: newDate)
            }

            Text("Tasks for \(selectedDate, formatter: itemDateFormatter)")
                .font(.headline)
                .padding(.top)

            // 3. Displaying Fetched Items
            if items.isEmpty {
                Text("No tasks due on this day.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(items) { item in
                        HStack {
                            Text(item.taskDescription ?? "Untitled Task")
                            Spacer()
                            if item.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("(Completed)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            Spacer() // To push content to the top if list is short
        }
        .navigationTitle("日曆頁面") // Updated title
    }
}

private let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .none
    return formatter
}()

#Preview {
    // CalendarView now expects to be in a context that might provide a NavigationView (like a Tab in ContentView)
    // or it can manage its own if it's the root of a tab.
    // For previewing CalendarView independently, wrapping it in NavigationView is good.
    NavigationView {
        CalendarView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
