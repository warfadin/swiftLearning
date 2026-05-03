import Cocoa


// class'lar için initializers konusundayım.

class Vehicle {
    let isElectric: Bool

    init(isElectric: Bool) {
        self.isElectric = isElectric
    }
}

// class Car: Vehicle {
//    let isConvertible: Bool

//    init(isConvertible: Bool) {
//        self.isConvertible = isConvertible
//    }
// }

// yukarıdaki halini Swift kabul etmiyor, çünkü Vehicle'dan inherit'leyen bir Car yaptık ama isElectric sorusuna cevabımız yok..
// O yüzden:

class Car1: Vehicle {
    let isConvertible: Bool
    
    init(isElectric: Bool, isConvertible: Bool) {
        self.isConvertible = isConvertible // car1 içindeki kendi propertyimiz
        super.init(isElectric: isElectric) // Vehicle içindeki property
    }
}

let tesla = Car1(isElectric: true, isConvertible: false)

// bununla birlikte, eğer child class'ın içinde init etmek istediğimiz bir şey yoksa, class'ın içindeki property'e örneğin default bir value vererek bütün custom init'i silip, Vehicle'daki init'i otomatik inherit etmesini sağlayabiliriz. bu durumda:

class Car2: Car1 {
    let isManual = false // property'e default olarak bi değer verdiğim için gerikalan (yani aslında "üstlerde kalan" propertylerin init'lerini Swift otomatik olarak init'liyor.
    }

let toyota = Car2(isElectric: false, isConvertible: false)

print(toyota.isManual)
