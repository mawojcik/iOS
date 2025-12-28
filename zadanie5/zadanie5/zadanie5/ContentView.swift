import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        if viewModel.isAuthenticated {
            VStack(spacing: 20) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.green)
                
                Text("Zalogowano pomyślnie!")
                    .font(.title)
                    .bold()
                
                Text("Twój token sesji:")
                    .foregroundColor(.gray)
                
                Text(viewModel.token)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Button("Wyloguj") {
                    viewModel.isAuthenticated = false
                    viewModel.email = ""
                    viewModel.password = ""
                }
                .padding()
            }
        } else {
            ZStack {
                VStack(spacing: 20) {
                    Text("Logowanie")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 30)
                    
                    TextField("Email", text: $viewModel.email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    SecureField("Hasło", text: $viewModel.password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    Button(action: {
                        viewModel.login()
                    }) {
                        Text("Zaloguj się")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    .disabled(viewModel.isLoading)
                }
                
                if viewModel.isLoading {
                    Color.black.opacity(0.4)
                        .edgesIgnoringSafeArea(.all)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2)
                }
            }
            .alert(isPresented: $viewModel.showError) {
                Alert(
                    title: Text("Błąd"),
                    message: Text(viewModel.errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
