import SwiftUI

struct TodoItem: Identifiable, Equatable {
    let id = UUID()
    let title: String
}

class TodoViewModel: ObservableObject {
    @Published var tasks: [TodoItem] = [
        TodoItem(title: "Zrobić zakupy spożywcze"),
        TodoItem(title: "Wyprowadzić psa"),
        TodoItem(title: "Opłacić rachunki"),
        TodoItem(title: "Umówić wizytę u lekarza")
    ]
    @Published var newTaskTitle: String = ""

    func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        tasks.append(TodoItem(title: newTaskTitle))
        newTaskTitle = ""
    }

    func deleteTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
    }
}

struct ContentView: View {
    @StateObject var viewModel = TodoViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Dodaj nowe zadanie...", text: $viewModel.newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(action: viewModel.addTask) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .disabled(viewModel.newTaskTitle.isEmpty)
                }
                .padding()

                List {
                    ForEach(viewModel.tasks) { task in
                        Text(task.title)
                    }
                    .onDelete(perform: viewModel.deleteTasks)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Lista Zadań")
            .toolbar {
                EditButton()
            }
        }
    }
}

#Preview {
    ContentView()
}
