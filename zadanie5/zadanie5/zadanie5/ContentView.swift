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
                    Text(viewModel.isLoginMode ? "Logowanie" : "Rejestracja")
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 10)
                    
                    Picker("Tryb", selection: $viewModel.isLoginMode) {
                        Text("Logowanie").tag(true)
                        Text("Rejestracja").tag(false)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    
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
                        viewModel.performAction()
                    }) {
                        Text(viewModel.isLoginMode ? "Zaloguj się" : "Zarejestruj się")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.isLoginMode ? Color.blue : Color.green)
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
            .alert(isPresented: $viewModel.registrationSuccess) {
                Alert(
                    title: Text("Sukces"),
                    message: Text("Konto zostało utworzone. Możesz się teraz zalogować."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
