import SwiftUI

struct TaskItem: Identifiable {
    let id = UUID()
    var title: String
    var icon: String
    var isCompleted: Bool
}

struct EditTaskView: View {
    @Binding var task: TaskItem

    var body: some View {
        Form {
            Section(header: Text("Szczegóły")) {
                TextField("Tytuł", text: $task.title)
                TextField("Emoji", text: $task.icon)
            }
            
            Section(header: Text("Status")) {
                Toggle("Zrobione", isOn: $task.isCompleted)
            }
        }
        .navigationTitle("Edycja zadania")
    }
}

struct ContentView: View {
    @State private var tasks: [TaskItem] = [
        TaskItem(title: "Zrobić zakupy spożywcze", icon: "🛒", isCompleted: false),
        TaskItem(title: "Wyprowadzić psa", icon: "🐕", isCompleted: true),
        TaskItem(title: "Napisać raport w pracy", icon: "💻", isCompleted: false),
        TaskItem(title: "Umyć samochód", icon: "🚗", isCompleted: false),
        TaskItem(title: "Przeczytać rozdział książki", icon: "📖", isCompleted: false),
        TaskItem(title: "Opłacić rachunki", icon: "💸", isCompleted: false)
    ]

    var body: some View {
        NavigationStack {
            List {
                ForEach($tasks) { $task in
                    HStack {
                        Image(systemName: $task.isCompleted.wrappedValue ? "checkmark.circle.fill" : "circle")
                            .font(.title2)
                            .foregroundColor($task.isCompleted.wrappedValue ? .green : .gray)
                            .onTapGesture {
                                withAnimation {
                                    $task.isCompleted.wrappedValue.toggle()
                                }
                            }
                        
                        NavigationLink(destination: EditTaskView(task: $task)) {
                            HStack {
                                Text($task.icon.wrappedValue)
                                    .font(.title2)
                                
                                Text($task.title.wrappedValue)
                                    .strikethrough($task.isCompleted.wrappedValue)
                                    .foregroundColor($task.isCompleted.wrappedValue ? .gray : .primary)
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Lista zadań")
        }
    }

    func deleteItems(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}
