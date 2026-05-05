import Cocoa

extension Numeric {
    func squared() -> Self { //current type [ eğer self (value olan) bir Int olursa Self de Int olur. Double olursa Double olur.
        self * self // current value e.g. 5, "hello"
    }
}
let wholeNumber = 2.4
print(wholeNumber.squared())

// Comparable, Equatable muhabbeti:

struct User: Equatable, Comparable {
    let name : String
    
    // left handside, right handside
    static func < (lhs: User, rhs: User) -> Bool {
        lhs.name < rhs.name
    }
}

// bir şeyi comparable yapınca, sadece < lessThan methodunu tanımlasan bile, bütün compare operatorlarını Swift kendi findoutlayabilir. (protocol inheritance)

let user1 = User(name: "A")
let user2 = User(name: "B")

print(user1 < user2)
print(user1 > user2) // mesela burada greaterThan'i yazmamıştım.
