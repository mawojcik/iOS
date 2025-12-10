import SwiftUI

struct Category: Codable, Identifiable {
    let id: Int
    let name: String
}

struct Product: Codable, Identifiable {
    let id: Int
    let name: String
    let price: Double
    let categoryId: Int
}

@MainActor
class StoreViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var products: [Product] = []
    
    func fetchData() async {
        do {
            if let url = URL(string: "http://127.0.0.1:3000/categories") {
                let (data, _) = try await URLSession.shared.data(from: url)
                self.categories = try JSONDecoder().decode([Category].self, from: data)
            }
            
            if let url = URL(string: "http://127.0.0.1:3000/products") {
                let (data, _) = try await URLSession.shared.data(from: url)
                self.products = try JSONDecoder().decode([Product].self, from: data)
            }
        } catch {
            print(error)
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = StoreViewModel()
    
    var body: some View {
        TabView {
            NavigationStack {
                List(viewModel.products) { product in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.name)
                                .font(.headline)
                            Text("ID Kategorii: \(product.categoryId)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(String(format: "%.2f", product.price))
                            .bold()
                    }
                }
                .navigationTitle("Produkty")
            }
            .tabItem {
                Label("Produkty", systemImage: "cart")
            }
            
            NavigationStack {
                List(viewModel.categories) { category in
                    HStack {
                        Text(category.name)
                        Spacer()
                        Text("ID: \(category.id)")
                            .foregroundStyle(.secondary)
                    }
                }
                .navigationTitle("Kategorie")
            }
            .tabItem {
                Label("Kategorie", systemImage: "list.bullet")
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }
}

#Preview {
    ContentView()
}
