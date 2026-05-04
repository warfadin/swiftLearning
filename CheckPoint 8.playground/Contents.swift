import Cocoa

protocol Building {
    var roomCount: Int { get }
    var cost: Int { get }
    var type: String { get }
    var estateAgent: String { get }
    func salesSummary() -> String
}

extension Building {
    func salesSummary() -> String {
        return "\(estateAgent) is selling a \(type) with \(roomCount) rooms for \(cost) dollars"
    }
}

struct House: Building {
    var roomCount: Int
    var cost: Int
    var estateAgent: String
    var type = "house"
}

struct Office: Building {
    var roomCount: Int
    var cost: Int
    var estateAgent: String
    var type = "office"
}

let house1 = House(roomCount: 3, cost: 100_000, estateAgent: "Bob")
let office1 = Office(roomCount: 10, cost: 1_000_000, estateAgent: "Bob")

print(house1.salesSummary())
print(office1.salesSummary())

