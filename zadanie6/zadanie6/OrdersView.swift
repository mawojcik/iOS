import SwiftUI

struct OrdersView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Order.id, ascending: true)],
        animation: .default)
    private var orders: FetchedResults<Order>
    
    var body: some View {
        
        NavigationView {
            List(orders, id: \.id) { order in
                OrderRow(order: order)
            }
            .navigationBarTitle("Orders", displayMode: .inline)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
}

struct OrderRow: View {
    @State private var isExpanded = false
    let order: Order
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Order Date: \(formattedDate(order.order_date ?? Date()))")
                    .font(.headline)
                Spacer()
                
                switch order.order_status{
                case "PROCESSING":
                    Image(systemName: "gear")
                        .foregroundColor(.blue)
                case "SHIPPED":
                    Image(systemName: "shippingbox")
                        .foregroundColor(.green)
                case "SEND":
                    Image(systemName: "paperplane")
                        .foregroundColor(.purple)
                default:
                    Text("Unknown Status")
                }
                
            }
            Text("Total Value: \(order.total_value)")
            
            if isExpanded {
                if let products = order.products?.allObjects as? [Product] {
                    ForEach(products, id: \.id) { product in
                        HStack {
                            Text("\(getCount(id:product.id, ordered_items:order.ordered_items as! [Int64]))x \(product.name ?? "Unknown Name")")
                            Spacer()
                            Text("\(product.price)")
                        }
                        .padding(5)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .onTapGesture {
            withAnimation {
                isExpanded.toggle()
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        return dateFormatter.string(from: date)
    }
    
    private func getCount(id: Int64, ordered_items: [Int64]) -> Int {
        return ordered_items.filter { $0 == id }.count
    }
}

#Preview {
    OrdersView()
}
