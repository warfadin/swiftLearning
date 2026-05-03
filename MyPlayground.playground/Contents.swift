import Cocoa

// static, mutating, throwing örneği
// gear kontrolü ve error handling
// Paul Hudson checkpoint 6'yı çözmeye çalıştım ama bokunu çıkardım bence


struct Car {
    enum CarError: Error {
        case gearNotAvailable
    }
    let model: String
    let year: Int
    let numberOfSeats: Int
    static let maxGear = 6
    private(set) var currentGear: Int {
        willSet {
            print("Gear is changing...")
        }
        didSet {
            print("Current gear is now: \(currentGear)")
        }
    }
    init(model: String, year: Int, numberOfSeats: Int, currentGear: Int) throws {
        if currentGear > Car.maxGear || currentGear <= 0 {
            throw CarError.gearNotAvailable
        }
        self.currentGear = currentGear
        self.model = model
        self.year = year
        self.numberOfSeats = numberOfSeats
    }
    
    mutating func gearUp(amount gear: Int) throws {
        if gear <= 0 || gear + currentGear > Car.maxGear {
            throw CarError.gearNotAvailable
        } else {
            currentGear += gear
        }
    } // mutating func burada bitiyor.
    
    mutating func gearDown(amount gear: Int) throws {
        if gear <= 0 || currentGear - gear <= 0 {
            throw CarError.gearNotAvailable
        } else {
            currentGear -= gear
        }
    }
}

do {
    var myCar = try Car(model: "Tesla", year: 2020, numberOfSeats: 5, currentGear: 1)
    try myCar.gearUp(amount: 5)
    try myCar.gearDown(amount: 1)
} catch Car.CarError.gearNotAvailable {
    print ("Gear is invalid")
}
