import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        NavigationView {
            VStack {
                if cartManager.items.isEmpty {
                    ContentUnavailableView("Twój koszyk jest pusty", systemImage: "cart")
                } else {
                    List {
                        ForEach(cartManager.items, id: \.self) { product in
                            HStack {
                                Text(product.name ?? "Produkt")
                                Spacer()
                                Text(String(format: "%.2f zł", product.price))
                            }
                        }
                        .onDelete { indexSet in
                            cartManager.remove(at: indexSet)
                        }
                    }
                }
                
                VStack {
                    Divider()
                    HStack {
                        Text("Suma:")
                            .font(.title2)
                        Spacer()
                        Text(String(format: "%.2f zł", cartManager.total))
                            .font(.title2)
                            .bold()
                    }
                    .padding()
                    
                    Button {
                        print("Przejdź do płatności")
                    } label: {
                        Text("Kupuję")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                }
                .background(Color(UIColor.systemBackground))
            }
            .navigationTitle("Koszyk")
        }
    }
}
