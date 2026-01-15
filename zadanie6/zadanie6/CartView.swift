import SwiftUI
import CoreData

struct CartView: View {
    @ObservedObject var cart: CartItems
    @State private var isPaymentViewPresented = false
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        
        VStack {
            List {
                ForEach(cart.items.sorted(by: <), id: \.key) { key, value in
                    HStack {
                        Text("\(fetchProduct(withId: key))")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Stepper(value: Binding(
                            get: { value },
                            set: { newValue in
                                if newValue == 0 {
                                    cart.items.removeValue(forKey: key)
                                }
                                else{
                                    cart.items[key] = newValue
                                }
                            }
                        )) {
                            Label(
                                title: { Text("\(value)") },
                                icon: { Image(systemName: "42.circle") }
                            ).labelStyle(.titleOnly)
                        }
                    }
                }
            }
            
            if !cart.items.isEmpty {
                Button(action: {
                    isPaymentViewPresented.toggle()
                }) {
                    Text("Go to payment")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $isPaymentViewPresented) {
                    PaymentView(cart: cart)
                }
                .padding(30)
            }
            Spacer()
        }
    }
    
    func fetchProduct(withId productId: Int) -> String {
            let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", productId)
            
            do {
                let products = try viewContext.fetch(fetchRequest)
                return products.first?.name ?? ""
            } catch {
                print("Error fetching product: \(error)")
                return ""
            }
        }
}

#Preview {
    CartView(cart: CartItems())
}
