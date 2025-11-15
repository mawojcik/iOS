import SwiftUI

struct ContentView: View {
    @State private var display: String = "0"
    @State private var accumulator: Double? = nil
    @State private var pendingOperator: String? = nil
    @State private var waitingForNewNumber = false
    @State private var operationDisplay: String = ""

    let buttons: [[String]] = [
        ["7","8","9","÷","log"],
        ["4","5","6","×","^"],
        ["1","2","3","−","±"],
        ["0",".","C","+","%"],
        ["="]
    ]

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 12) {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(operationDisplay)
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    Text(display)
                        .font(.system(size: min(geo.size.width, geo.size.height) * 0.12))
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
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
                                    .background(buttonBackground(title))
                                    .foregroundColor(buttonForeground(title))
                                    .cornerRadius(12)
                            }
                        }
                        if row.count < 5 {
                            ForEach(0..<(5 - row.count), id: \.self) { _ in
                                Spacer(minLength: 0).frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func buttonBackground(_ title: String) -> Color {
        switch title {
        case "C": return Color(.systemRed)
        case "+", "−", "×", "÷", "=","^","log","±","%": return Color(.systemOrange)
        default: return Color(.systemGray5)
        }
    }

    private func buttonForeground(_ title: String) -> Color {
        switch title {
        case "C", "+", "−", "×", "÷", "=","^","log","±","%": return .white
        default: return .primary
        }
    }

    private func buttonHeight(for geo: GeometryProxy) -> CGFloat {
        return (geo.size.height - 200) / 10
    }

    private func buttonPressed(_ value: String) {
        switch value {
        case "C":
            clearAll()
            operationDisplay = ""
        case "+", "−", "×", "÷","^":
            if accumulator == nil {
                accumulator = Double(display)
            } else if !waitingForNewNumber {
                applyPendingOperator()
            }
            pendingOperator = value
            waitingForNewNumber = true
            operationDisplay = "\(formatted(accumulator ?? 0)) \(value)"
        case "=":
            applyPendingOperator()
            pendingOperator = nil
            waitingForNewNumber = true
            accumulator = Double(display)
            operationDisplay = ""
        case ".":
            insertDecimal()
        case "±":
            if let current = Double(display) {
                display = formatted(-current)
            }
        case "%":
            if let current = Double(display) {
                let percentValue = current / 100
                display = formatted(percentValue)
                if accumulator == nil || waitingForNewNumber {
                    accumulator = percentValue
                }
                waitingForNewNumber = true
            }
        case "log":
            if let current = Double(display), current > 0 {
                display = formatted(log10(current))
                accumulator = Double(display)
            } else {
                display = "Error"
                accumulator = nil
                pendingOperator = nil
                operationDisplay = ""
            }
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

    private func insertDecimal() {
        if waitingForNewNumber {
            display = "0."
            waitingForNewNumber = false
        } else if !display.contains(".") {
            display += "."
        }
    }

    private func applyPendingOperator() {
        let current = Double(display) ?? 0
        if let op = pendingOperator, let acc = accumulator {
            var result = acc
            switch op {
            case "+":
                result = acc + current
            case "−":
                result = acc - current
            case "×":
                result = acc * current
            case "÷":
                if current != 0 {
                    result = acc / current
                } else {
                    display = "Error"
                    accumulator = nil
                    pendingOperator = nil
                    operationDisplay = ""
                    return
                }
            case "^":
                result = pow(acc, current)
            default: break
            }
            accumulator = result
            display = formatted(result)
        } else {
            accumulator = current
        }
    }


    private func formatted(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    private func clearAll() {
        display = "0"
        accumulator = nil
        pendingOperator = nil
        waitingForNewNumber = false
    }
}



#Preview {
    ContentView()
}
