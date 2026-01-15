import SwiftUI

struct AddProductView: View {
    @ObservedObject var category: Category
    @State private var name:String = ""
    @State private var price:String = ""
    @State private var isShowingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var didAddProduct: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        Form {
            TextField("Name", text: $name)
            TextField("Price", text: $price)
            
            Button("Add") {
                addProduct()
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        .onChange(of: didAddProduct) {
            if didAddProduct {
                dismiss()
            }
        }
    }
    
    private func showAlert(message: String) {
        alertMessage = message
        isShowingAlert = true
    }
    
    private func addProduct() {
        guard !name.isEmpty else {
            showAlert(message: "Name cannot be empty")
            return
        }
        
        guard let priceValue = Double(price), priceValue >= 0.0 else {
            showAlert(message: "Invalid price. Please enter a valid positive number.")
            return
        }
        
        guard let url = URL(string: "http://127.0.0.1:5000/product") else {
            return
        }
        
        let productData: [String: Any] = [
            "name": name,
            "price": Double(price) ?? 0.0,
            "category_id": category.id
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: productData) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let id = try JSONDecoder().decode(Int64.self, from: data)
                DispatchQueue.main.async {
                    let product = Product(context: viewContext)
                    product.name = name
                    product.price = Double(price) ?? 0.0
                    product.category = category
                    product.category_id = category.id
                    product.id = id
                    
                    do {
                        try viewContext.save()
                        didAddProduct = true
                    } catch {
                        print("Error adding")
                    }
                }
            } catch {
                print("Error decoding data: \(error.localizedDescription)")
            }
        }.resume()
    }
}
