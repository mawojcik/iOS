import SwiftUI
import CoreData

struct PaymentView: View {
    @ObservedObject var cart: CartItems
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var cardNumber = ""
    @State private var ccv = ""
    @State private var isShowingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack(spacing: 24) {
            VStack {
                InputView(text: $cardNumber, title: "Card number:", placeholder: "Enter card number")
                    .autocapitalization(.none)
                
                InputView(text: $ccv, title: "CCV:", placeholder: "Enter CCV")
                    .autocapitalization(.none)
            }
            .padding(.horizontal)
            .padding(.top, 100)
            
            Button(action: {
                makeStandardPayment(cardNumber: cardNumber, ccv: ccv)
                
            }, label: {
                HStack {
                    Text("PAY")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 30, height: 40)
            })
            .background(Color(.systemBlue))
            .cornerRadius(9.0)
            .padding(.top, 15)
            .alert(isPresented: $isShowingAlert ) {
                Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .onDisappear {
                isShowingAlert = false
                alertMessage = ""
            }
            Spacer()
        }
    }
    
    func makeStandardPayment(cardNumber: String, ccv: String) {
        guard !cardNumber.isEmpty, !ccv.isEmpty else {
            isShowingAlert = true
            alertMessage = "Wprowadź poprawne dane."
            return
        }
        
        let cardNumberCharacterSet = CharacterSet.decimalDigits
        guard cardNumber.rangeOfCharacter(from: cardNumberCharacterSet.inverted) == nil,
              ccv.rangeOfCharacter(from: cardNumberCharacterSet.inverted) == nil else {
            isShowingAlert = true
            alertMessage = "Wprowadź poprawne dane składające się z samych cyfr."
            return
        }
        
        cart.items.removeAll()
    }
}

#Preview {
    PaymentView(cart: CartItems())
}
