import SwiftUI

struct ProductDetailView: View {
    let product: Product

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(product.name ?? "Nieznany produkt")
                    .font(.largeTitle)
                    .bold()
                
                if let categoryName = product.category?.name {
                    Text("Kategoria: \(categoryName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(5)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(5)
                }
                
                Divider()
                
                Text("Opis:")
                    .font(.headline)
                
                Text(product.desc ?? "Brak opisu")
                    .font(.body)
                
                Spacer()
                
                Text(String(format: "Cena: %.2f zł", product.price))
                    .font(.title2)
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
        }
        .navigationTitle("Szczegóły")
        .navigationBarTitleDisplayMode(.inline)
    }
}
