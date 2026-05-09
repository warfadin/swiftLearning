import Foundation

struct ToolDefinition: Identifiable, Equatable {
    enum ToolID: String {
        case vasoactiveCalculator
    }

    let id: ToolID
    let title: String
    let subtitle: String
    let systemImage: String
    let isEnabled: Bool
}

extension ToolDefinition {
    static let availableTools: [ToolDefinition] = [
        ToolDefinition(
            id: .vasoactiveCalculator,
            title: "Vazoaktif Ajan Hesaplayıcı",
            subtitle: "Doz, infüzyon hızı ve karışım hesaplama",
            systemImage: "cross.case.fill",
            isEnabled: true
        )
    ]
}
