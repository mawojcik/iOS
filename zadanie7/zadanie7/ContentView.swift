import SwiftUI

struct ContentView: View {
    struct TodoItem: Identifiable {
        let id = UUID()
        let title: String
    }

    @State private var tasks: [TodoItem] = [
        TodoItem(title: "Zrobić zakupy spożywcze"),
        TodoItem(title: "Wyprowadzić psa"),
        TodoItem(title: "Opłacić rachunki"),
        TodoItem(title: "Umówić wizytę u lekarza")
    ]
    
    @State private var newTaskTitle: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Dodaj nowe zadanie...", text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(newTaskTitle.isEmpty)
                }
                .padding()

                List {
                    ForEach(tasks) { task in
                        Text(task.title)
                    }
                    .onDelete(perform: deleteTasks)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Lista Zadań")
            .toolbar {
                EditButton()
            }
        }
    }

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        let newTask = TodoItem(title: newTaskTitle)
        withAnimation {
            tasks.append(newTask)
            newTaskTitle = ""
        }
    }

    private func deleteTasks(at offsets: IndexSet) {
        withAnimation {
            tasks.remove(atOffsets: offsets)
        }
    }
}

#Preview {
    ContentView()
}
