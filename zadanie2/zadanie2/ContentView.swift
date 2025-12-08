import SwiftUI

struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
}

struct ContentView: View {
    let tasks: [TaskItem] = [
        TaskItem(title: "Zrobić zakupy spożywcze", icon: "🛒"),
                TaskItem(title: "Wyprowadzić psa", icon: "🐕"),
                TaskItem(title: "Napisać raport w pracy", icon: "💻"),
                TaskItem(title: "Umyć samochód", icon: "🚗"),
                TaskItem(title: "Przeczytać rozdział książki", icon: "📖"),
                TaskItem(title: "Opłacić rachunki", icon: "💸")
    ]

    var body: some View {
        NavigationStack {
            List(tasks) { task in
                HStack {
                    Text(task.icon)
                        .font(.title2)
                    Text(task.title)
                }
            }
            .navigationTitle("Lista zadań")
        }
    }
}

#Preview {
    ContentView()
}
