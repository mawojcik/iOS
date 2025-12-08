import SwiftUI
import CoreData

struct ContentView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        TabView {
            // Zakładka 1: Sklep
            ProductListView()
                .tabItem {
                    Label("Sklep", systemImage: "bag")
                }
            
            // Zakładka 2: Koszyk
            CartView()
                .tabItem {
                    Label("Koszyk", systemImage: "cart")
                }
                // Opcjonalnie: Czerwona kropka z liczbą produktów (iOS 15+)
                .badge(cartManager.items.count)
        }
    }
}

struct ProductListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)],
        animation: .default)
    private var products: FetchedResults<Product>
    
    var body: some View {
        NavigationView {
            List {
                ForEach(products) { product in
                    NavigationLink {
                        ProductDetailView(product: product)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(product.name ?? "Bez nazwy")
                                    .font(.headline)
                                Text(product.category?.name ?? "Brak kategorii")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Text(String(format: "%.0f zł", product.price))
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Produkty")
        }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(CartManager())
}
