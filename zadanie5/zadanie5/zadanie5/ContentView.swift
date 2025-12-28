import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = LoginViewModel()
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationView {
            if viewModel.isAuthenticated {
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.green)

                    Text("Zalogowano pomyślnie!")
                        .font(.title)
                        .bold()

                    Text("Twój token:")
                        .foregroundColor(.gray)

                    Text(viewModel.token)
                        .font(.system(.caption, design: .monospaced))
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .lineLimit(1)
                        .truncationMode(.middle)

                    Button("Wyloguj") {
                        viewModel.logout()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .navigationTitle("Zadanie5")
            } else {
                VStack(spacing: 16) {
                    Picker("", selection: $viewModel.isLoginMode) {
                        Text("Logowanie").tag(true)
                        Text("Rejestracja").tag(false)
                    }
                    .pickerStyle(.segmented)

                    Text(viewModel.isLoginMode ? "Logowanie" : "Rejestracja")
                        .font(.title2)
                        .bold()

                    TextField("Email", text: $viewModel.email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textFieldStyle(.roundedBorder)

                    SecureField("Hasło", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)

                    if let info = viewModel.infoText {
                        Text(info)
                            .foregroundColor(.green)
                            .font(.footnote)
                    }

                    if viewModel.showError {
                        Text(viewModel.errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }

                    Button {
                        viewModel.performAction()
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text(viewModel.isLoginMode ? "Zaloguj" : "Zarejestruj")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(viewModel.isLoading)

                    if viewModel.isLoginMode {
                        Button {
                            viewModel.googleLogin()
                        } label: {
                            Text("Zaloguj przez Google")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        Button {
                            Task { await viewModel.startGitHubDeviceFlow() }
                        } label: {
                            Text("Zaloguj przez GitHub")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)

                        if let code = viewModel.ghUserCode,
                           let url = viewModel.ghVerificationURL {
                            VStack(spacing: 8) {
                                Text(code)
                                    .font(.title)
                                    .bold()

                                Button("Otwórz GitHub") {
                                    openURL(url)
                                }
                                .buttonStyle(.borderedProminent)

                                Button("Anuluj") {
                                    viewModel.stopGitHubFlow()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle("Zadanie5")
            }
        }
    }
}
