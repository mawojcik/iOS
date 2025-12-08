import SwiftUI

class CartManager: ObservableObject {
    @Published var items: [Product] = []
    
    func add(product: Product) {
        items.append(product)
    }
    
    func remove(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    var total: Double {
        items.reduce(0) { $0 + ($1.price) }
    }
}
