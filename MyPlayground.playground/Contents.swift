import Cocoa

// class ve struct arasındaki farklar:
// class üstüne class girebilirsin (inheritance)
// class'larda swift kendi default memberwise init yapmıyor
// class içerisinde bir instance'ın kopyasını oluşturup instance'ı değiştirirsen orijinal class'taki datayı da değiştirir.
// deinitializer ile final kopya destroy edilebilir .
// constant class instance'ların varieble property'leri değiştirilebilir.

class Game {
    var score = 0 {
        didSet {
            print("\(score)")
        }
    }
}

var newGame = Game()
newGame.score = 10

// ile alttaki şey aynı aslında

struct Game1 {
    var score = 0 {
        didSet {
            print("\(score)")
        }
    }
}

var newGame2 = Game1()
newGame2.score = 10
