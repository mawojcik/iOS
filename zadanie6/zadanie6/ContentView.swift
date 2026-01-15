import SwiftUI
import CoreData

class CartItems: ObservableObject {
    @Published var items: [Int: Int] = [:]
    
    func addToCart(productId: Int) {
        if let existingValue = items[productId] {
            items[productId] = existingValue + 1
        } else {
            items[productId] = 1
        }
    }
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>
    
    @State var tabSelection = 0
    
    @ObservedObject var cart = CartItems()
    
    var body: some View {
        
        TabView(selection: $tabSelection) {
            NavigationView {
                List {
                    ForEach(categories) { category in
                        HStack{
                            NavigationLink(category.name!, destination: CategoryView(category: category, cart: cart))
                        }
                    }
                }
            }.tabItem {
                Image(systemName: "list.dash")
                Text("Categories")
            }.tag(0)
            
            CartView(cart: cart).tabItem {
                Image(systemName: "cart")
                Text("Cart")
            }.tag(1)
            
            OrdersView().tabItem {
                Image(systemName: "giftcard.fill")
                Text("Orders")
            }.tag(1)
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
