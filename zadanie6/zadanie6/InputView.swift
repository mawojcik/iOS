import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .fontWeight(.semibold)
            TextField(placeholder, text: $text)
            Divider()
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Card number", placeholder: "123456789")
}
