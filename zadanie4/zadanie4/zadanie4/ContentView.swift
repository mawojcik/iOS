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

struct OrderItemDTO: Codable {
    let id: Int
    let productId: Int
    let quantity: Int
    let unitPrice: Double
}

struct OrderDTO: Codable {
    let id: Int
    let customerName: String
    let createdAt: String
    let status: String
    let note: String?
    let items: [OrderItemDTO]
}

@MainActor
class DataSyncManager: ObservableObject {
    @Published var lastError: String? = nil
    
    func syncData(context: NSManagedObjectContext) async {
        self.lastError = nil
        
        do {
            if let url = URL(string: "http://127.0.0.1:3000/categories") {
                let (data, _) = try await URLSession.shared.data(from: url)
                let categories = try JSONDecoder().decode([CategoryDTO].self, from: data)
                
                await context.perform {
                    let fetchRequest: NSFetchRequest<CategoryEntity> = CategoryEntity.fetchRequest()
                    if let existing = try? context.fetch(fetchRequest) {
                        for obj in existing { context.delete(obj) }
                    }
                    
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
                    let fetchRequest: NSFetchRequest<ProductEntity> = ProductEntity.fetchRequest()
                    if let existing = try? context.fetch(fetchRequest) {
                        for obj in existing { context.delete(obj) }
                    }
                    
                    for prod in products {
                        let newProd = ProductEntity(context: context)
                        newProd.id = Int64(prod.id)
                        newProd.name = prod.name
                        newProd.price = prod.price
                        newProd.categoryId = Int64(prod.categoryId)
                    }
                }
            }
            
            if let url = URL(string: "http://127.0.0.1:3000/orders") {
                let (data, _) = try await URLSession.shared.data(from: url)
                let orders = try JSONDecoder().decode([OrderDTO].self, from: data)
                
                await context.perform {
                    let fetchRequest: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
                    if let existing = try? context.fetch(fetchRequest) {
                        for obj in existing { context.delete(obj) }
                    }
                    
                    let itemRequest: NSFetchRequest<OrderItemEntity> = OrderItemEntity.fetchRequest()
                    if let existingItems = try? context.fetch(itemRequest) {
                        for obj in existingItems { context.delete(obj) }
                    }
                    
                    for orderData in orders {
                        let newOrder = OrderEntity(context: context)
                        newOrder.id = Int64(orderData.id)
                        newOrder.customerName = orderData.customerName
                        newOrder.createdAt = orderData.createdAt
                        newOrder.status = orderData.status
                        newOrder.note = orderData.note
                        
                        for itemData in orderData.items {
                            let newItem = OrderItemEntity(context: context)
                            newItem.id = Int64(itemData.id)
                            newItem.productId = Int64(itemData.productId)
                            newItem.quantity = Int64(itemData.quantity)
                            newItem.unitPrice = itemData.unitPrice
                            newItem.order = newOrder
                        }
                    }
                    
                    try? context.save()
                }
            }
            
        } catch {
            self.lastError = "Błąd: \(error.localizedDescription)"
            print("SYNC ERROR: \(error)")
        }
    }
}

extension OrderEntity {
    public var itemsArray: [OrderItemEntity] {
        let set = items as? Set<OrderItemEntity> ?? []
        return set.sorted { $0.id < $1.id }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var syncManager = DataSyncManager()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ProductEntity.name, ascending: true)],
        animation: .default)
    private var products: FetchedResults<ProductEntity>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CategoryEntity.id, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<CategoryEntity>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \OrderEntity.id, ascending: true)],
        animation: .default)
    private var orders: FetchedResults<OrderEntity>
    
    var body: some View {
        TabView {
            NavigationStack {
                VStack {
                    if let error = syncManager.lastError {
                        Text(error)
                            .foregroundStyle(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                            .padding()
                    }
                    
                    List(orders) { order in
                        NavigationLink(destination: OrderDetailView(order: order)) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Zamówienie #\(order.id)")
                                        .bold()
                                    Spacer()
                                    Text(order.status ?? "")
                                        .font(.caption)
                                        .padding(5)
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(5)
                                }
                                Text(order.customerName ?? "")
                                Text(order.createdAt ?? "")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .refreshable {
                        await syncManager.syncData(context: viewContext)
                    }
                }
                .navigationTitle("Zamówienia")
            }
            .tabItem {
                Label("Zamówienia", systemImage: "shippingbox")
            }
            
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
                .navigationTitle("Produkty")
                .refreshable {
                    await syncManager.syncData(context: viewContext)
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
                .navigationTitle("Kategorie")
                .refreshable {
                    await syncManager.syncData(context: viewContext)
                }
            }
            .tabItem {
                Label("Kategorie", systemImage: "list.bullet")
            }
        }
        .task {
            await syncManager.syncData(context: viewContext)
        }
    }
}

struct OrderDetailView: View {
    let order: OrderEntity
    
    var body: some View {
        List {
            Section(header: Text("Szczegóły")) {
                Text("Klient: \(order.customerName ?? "")")
                Text("Data: \(order.createdAt ?? "")")
                Text("Status: \(order.status ?? "")")
                if let note = order.note, !note.isEmpty {
                    Text("Notatka: \(note)")
                        .italic()
                }
            }
            
            Section(header: Text("Pozycje zamówienia")) {
                ForEach(order.itemsArray) { item in
                    HStack {
                        Text("Produkt ID: \(item.productId)")
                        Spacer()
                        Text("\(item.quantity) x \(String(format: "%.2f", item.unitPrice))")
                    }
                }
            }
        }
        .navigationTitle("Zamówienie #\(order.id)")
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
