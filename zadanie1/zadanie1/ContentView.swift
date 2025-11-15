import SwiftUI

struct ContentView: View {
    @State private var display: String = "0"
    @State private var accumulator: Double? = nil
    @State private var pendingOperator: String? = nil
    @State private var waitingForNewNumber: Bool = false

    let buttons: [[String]] = [
        ["7","8","9","+"],
        ["4","5","6","="],
        ["1","2","3","C"],
        ["0"]
    ]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 12) {
                Spacer()

                Text(display)
                    .font(.system(size: min(geo.size.width, geo.size.height) * 0.12))
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)

                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(row, id: \.self) { title in
                            Button(action: { buttonPressed(title) }) {
                                Text(title)
                                    .font(.system(size: 28, weight: .medium))
                                    .frame(height: buttonHeight(for: geo))
                                    .frame(maxWidth: .infinity)
                                    .background(buttonBackground(title: title))
                                    .foregroundColor(buttonForeground(title: title))
                                    .cornerRadius(12)
                            }
                        }

                        if row.count < 4 {
                            ForEach(0..<(4 - row.count), id: \.self) { _ in
                                Spacer(minLength: 0)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func buttonHeight(for geo: GeometryProxy) -> CGFloat {
        let totalSpacing: CGFloat = 12 * 4 + 16
        let available = geo.size.height - 200 - totalSpacing
        return max(44, available / 8)
    }

    private func buttonBackground(title: String) -> Color {
        if title == "C" { return Color(.systemRed).opacity(0.85) }
        if title == "+" || title == "=" { return Color(.systemOrange).opacity(0.9) }
        return Color(.systemGray5)
    }
    private func buttonForeground(title: String) -> Color {
        if title == "C" || title == "+" || title == "=" { return .white }
        return .primary
    }

    private func buttonPressed(_ value: String) {
        switch value {
        case "C":
            clearAll()
        case "+":
            applyPendingOperatorIfNeeded()
            pendingOperator = "+"
            waitingForNewNumber = true
        case "=":
            applyPendingOperatorIfNeeded()
            pendingOperator = nil
            waitingForNewNumber = true
        default:
            handleDigit(value)
        }
    }

    private func handleDigit(_ digit: String) {
        if waitingForNewNumber || display == "0" {
            display = digit
            waitingForNewNumber = false
        } else {
            display += digit
        }
    }

    private func applyPendingOperatorIfNeeded() {
        let current = Double(display) ?? 0.0

        if let op = pendingOperator, let acc = accumulator {
            switch op {
            case "+":
                let result = acc + current
                accumulator = result
                display = formatted(result)
            default:
                break
            }
        } else {
            accumulator = current
        }
    }

    private func clearAll() {
        display = "0"
        accumulator = nil
        pendingOperator = nil
        waitingForNewNumber = false
    }

    private func formatted(_ value: Double) -> String {
        if value.rounded(.towardZero) == value {
            return String(Int(value))
        } else {
            return String(value)
        }
    }
}


#Preview {
    ContentView()
}
