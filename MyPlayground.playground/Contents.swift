import Cocoa


// inheritance konusundayım.


class Employee {
    let hours: Int
    init(hours: Int) {
        self.hours = hours
    }
    func printSummary() {
        print ("I work \(hours) a day")
    }
}


// class Developer'ın önüne final eklersem, bu artık son child class olur ve artık Developer class'ından daha child bir class oluşturulamaz.

class Developer: Employee { // üstteki Employee class'ından bütün özellikleri inheritlemiş oldu, init dahil.
    func work() { // buradaki func ile aşağıdaki func'ın ismi aynı olmasına rağmen Developer de Manager de yine Employee class'ından inheritlendiği için çağrılırken swift bunun hangi class'tan geldiğini anlayacak.
        print("I'm writing code for \(hours) hours")
    }
    override func printSummary() {
        print("I'm a developer who will sometimes work \(hours) hours a day, but other times will spend hours arguing.")
    }
}

class Manager: Employee {
    func work () {
        print("I'm going to meetings for \(hours)")
    }
}

let robert = Developer(hours: 10) // robert'i developer yaptı ve Employee class'ındaki hours propertysini kullanarak Developer içindeki work methodunu çalıştırdı.
let joseph = Manager(hours: 10) // aynısını Employee'den inheritleyip manager'daki work methodunu çalıştırdık.
robert.work() // robert instance'ının içinde work methodunu kullandı, robert bir developer olduğu için onun içindeki work methodunu kullandığı için "writing code ...." şeklinde çıktı verdi.
joseph.work()

let mehmet = Manager(hours: 12)
mehmet.printSummary() // burada mehmet'i manager yaptık ve 12. satırdaki Employee classındaki method Developer için de geçerli olduğu için direk kullanabildik.

let altay = Developer(hours: 2)
altay.printSummary() // burada altayı Developer yaptık ve Developer class'ının içindeki override func'ında ana Class (Employee'deki) printSummary'ı modify ettiğimiz için artık developer içindeki override edilmiş methodun sonucunu gösteriyor.


