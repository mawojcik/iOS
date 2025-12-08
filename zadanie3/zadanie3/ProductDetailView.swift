import SwiftUI

struct ProductDetailView: View {
    let product: Product
    
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text(product.name ?? "Nieznany produkt")
                    .font(.largeTitle)
                    .bold()
                
                if let categoryName = product.category?.name {
                    Text("Kategoria: \(categoryName)")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.gray)
                        .cornerRadius(8)
                }
                
                Divider()
                
                Text("Opis")
                    .font(.headline)
                
                Text(product.desc ?? "Brak opisu dla tego produktu.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(5)
                
                Spacer()
                
                VStack(spacing: 15) {
                    Divider()
                    
                    HStack {
                        Text("Cena:")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.2f zł", product.price))
                            .font(.title)
                            .bold()
                            .foregroundColor(.blue)
                    }
                    
                    Button {
                        cartManager.add(product: product)
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    } label: {
                        HStack {
                            Image(systemName: "cart.badge.plus")
                            Text("Dodaj do koszyka")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                    }
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Szczegóły")
        .navigationBarTitleDisplayMode(.inline)
    }
}

