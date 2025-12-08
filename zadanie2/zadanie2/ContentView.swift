import SwiftUI

struct TaskItem: Identifiable {
    let id = UUID()
    let title: String
}

struct ContentView: View {
    let tasks: [TaskItem] = [
        TaskItem(title: "Zrobić zakupy spożywcze"),
        TaskItem(title: "Wyprowadzić psa"),
        TaskItem(title: "Napisać raport w pracy"),
        TaskItem(title: "Umyć samochód"),
        TaskItem(title: "Przeczytać rozdział książki"),
        TaskItem(title: "Opłacić rachunki")
    ]

    var body: some View {
        NavigationStack {
            List(tasks) { task in
                HStack {
                    Image(systemName: "circle")
                        .foregroundColor(.blue)
                    Text(task.title)
                        .font(.body)
                }
            }
            .navigationTitle("Lista zadań")
        }
    }
}

#Preview {
    ContentView()
}
