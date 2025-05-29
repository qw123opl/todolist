import SwiftUI
import CoreData

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // 3. FetchRequest for Completed TodoItems
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TodoItem.completedDate, ascending: false)],
        predicate: NSPredicate(format: "isCompleted == %@", NSNumber(value: true)),
        animation: .default)
    private var completedItems: FetchedResults<TodoItem>

    var body: some View {
        NavigationView {
            VStack {
                // 4. Displaying Fetched Items
                if completedItems.isEmpty {
                    Text("No completed tasks yet.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(completedItems) { item in
                            VStack(alignment: .leading) {
                                Text(item.taskDescription ?? "Untitled Task")
                                    .font(.headline)
                                Text("Completed: \(item.completedDate ?? Date(), formatter: itemDateFormatter)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("歷史紀錄頁面") // Updated title
        }
    }
}

private let itemDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    HistoryView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
