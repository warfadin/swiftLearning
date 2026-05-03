import Cocoa

// CheckPoint 7 için çözümüm

class Animal {
    var legs: Int
    init(legs: Int) {
        self.legs = legs
    }
}

class Dogs: Animal {
    func speak() {
        print("bark")
    }
}

class Corgi: Dogs {
    override func speak() {
        print("woof")
    }
}

class Poodle: Dogs{
    override func speak() {
        print("pup")
    }
}

class Cats: Animal {
    var isTame: Bool
    init(isTame: Bool) {
        self.isTame = isTame
        super.init(legs: 4)
    }
    func speak() {
        print("meow")
    }
}

final class Persian: Cats {
    override func speak() {
        print("miaow")
    }
}

final class Lion: Cats {
    override func speak() {
        print("roar")
    }
}
