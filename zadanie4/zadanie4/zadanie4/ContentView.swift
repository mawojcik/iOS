import SwiftUI
import CoreData

struct CategoryDTO: Codable {
    let id: Int
    let name: String
}

struct ProductDTO: Codable {
    let id: Int
    let name: String
    let price: Double
    let categoryId: Int
}

class DataSyncManager {
    static func syncData(context: NSManagedObjectContext) async {
        do {
            if let url = URL(string: "http://127.0.0.1:3000/categories") {
                let (data, _) = try await URLSession.shared.data(from: url)
                let categories = try JSONDecoder().decode([CategoryDTO].self, from: data)
                
                await context.perform {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CategoryEntity.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try? context.execute(deleteRequest)
                    
                    for cat in categories {
                        let newCat = CategoryEntity(context: context)
                        newCat.id = Int64(cat.id)
                        newCat.name = cat.name
                    }
                }
            }
            
            if let url = URL(string: "http://127.0.0.1:3000/products") {
                let (data, _) = try await URLSession.shared.data(from: url)
                let products = try JSONDecoder().decode([ProductDTO].self, from: data)
                
                await context.perform {
                    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ProductEntity.fetchRequest()
                    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                    try? context.execute(deleteRequest)
                    
                    for prod in products {
                        let newProd = ProductEntity(context: context)
                        newProd.id = Int64(prod.id)
                        newProd.name = prod.name
                        newProd.price = prod.price
                        newProd.categoryId = Int64(prod.categoryId)
                    }
                    
                    try? context.save()
                }
            }
        } catch {
            print(error)
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ProductEntity.name, ascending: true)],
        animation: .default)
    private var products: FetchedResults<ProductEntity>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.id, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<CategoryEntity>
    
    var body: some View {
        TabView {
            NavigationStack {
                List(products) { product in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(product.name ?? "")
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
                .navigationTitle("Produkty (Lokalne)")
                .refreshable {
                    await DataSyncManager.syncData(context: viewContext)
                }
            }
            .tabItem {
                Label("Produkty", systemImage: "cart")
            }
            
            NavigationStack {
                List(categories) { category in
                    HStack {
                        Text(category.name ?? "")
                        Spacer()
                        Text("ID: \(category.id)")
                            .foregroundStyle(.secondary)
                    }
                }
                .navigationTitle("Kategorie (Lokalne)")
                .refreshable {
                    await DataSyncManager.syncData(context: viewContext)
                }
            }
            .tabItem {
                Label("Kategorie", systemImage: "list.bullet")
            }
        }
        .task {
            if products.isEmpty && categories.isEmpty {
                await DataSyncManager.syncData(context: viewContext)
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
