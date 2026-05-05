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

//----------------------------------

protocol Vehicle {
    func estimateTime(for distance: Int) -> Int
    func travel(distance: Int) // Protokollerde body'e kod yazılmıyor.
}

struct Car: Vehicle {
    func estimateTime(for distance: Int) -> Int {
    distance / 50
    }
    
    func travel(distance: Int) {
    print("I'm driving \(distance)km") // Protocol'deki iki fonksiyonu da kullandı. ve body'e kodu struct'ın içinde yazdı.
}
    func openSunroof() { // protocolde olmayan extra func yazılması serbest
    print("I's a sunny day")
    }
}

func commute(distance: Int, using vehicle: Vehicle) {
    if vehicle.estimateTime(for: distance) > 100 {
    print ("Too slow")
    } else {
    vehicle.travel(distance:distance)
    }
}

let car = Car()
commute(distance: 100, using: car)
