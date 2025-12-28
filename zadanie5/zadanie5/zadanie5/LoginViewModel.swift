import Foundation
import SwiftUI

struct AuthRequest: Encodable {
    let email: String
    let password: String
}

struct TokenResponse: Decodable {
    let token: String
}

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var token = ""
    @Published var errorMessage = ""
    @Published var showError = false
    @Published var isLoading = false
    @Published var isLoginMode = true
    @Published var registrationSuccess = false
    
    private let baseURL = "http://127.0.0.1:8000"
    
    func performAction() {
        if isLoginMode {
            login()
        } else {
            register()
        }
    }
    
    func login() {
        guard let url = URL(string: "\(baseURL)/login") else { return }
        executeRequest(url: url)
    }
    
    func register() {
        guard let url = URL(string: "\(baseURL)/register") else { return }
        executeRequest(url: url)
    }
    
    private func executeRequest(url: URL) {
        isLoading = true
        
        let body = AuthRequest(email: email, password: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if error != nil {
                    self?.errorMessage = "Błąd połączenia z serwerem"
                    self?.showError = true
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    self?.errorMessage = "Nieznany błąd serwera"
                    self?.showError = true
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    if self?.isLoginMode == true {
                        if let data = data, let decodedResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) {
                            self?.token = decodedResponse.token
                            self?.isAuthenticated = true
                        }
                    } else {
                        self?.registrationSuccess = true
                        self?.isLoginMode = true
                    }
                } else {
                    self?.handleError(statusCode: httpResponse.statusCode)
                }
            }
        }.resume()
    }
    
    private func handleError(statusCode: Int) {
        switch statusCode {
        case 400:
            errorMessage = "Brak email lub hasła"
        case 401:
            errorMessage = "Niepoprawny email lub hasło"
        case 409:
            errorMessage = "Taki użytkownik już istnieje"
        default:
            errorMessage = "Błąd serwera: \(statusCode)"
        }
        showError = true
    }
}
