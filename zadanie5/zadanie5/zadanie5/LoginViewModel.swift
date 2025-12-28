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
    
    func login() {
        guard let url = URL(string: "http://127.0.0.1:8000/login") else { return }
        
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
                
                if httpResponse.statusCode == 200, let data = data {
                    if let decodedResponse = try? JSONDecoder().decode(TokenResponse.self, from: data) {
                        self?.token = decodedResponse.token
                        self?.isAuthenticated = true
                        return
                    }
                } else if httpResponse.statusCode == 401 {
                    self?.errorMessage = "Niepoprawny email lub hasło"
                    self?.showError = true
                } else {
                    self?.errorMessage = "Błąd serwera: \(httpResponse.statusCode)"
                    self?.showError = true
                }
            }
        }.resume()
    }
}
