// GUARD LET

func printSquare(of number: Int?) {
    guard let number = number else {
        print("Missing input")
        return // guard let her zaman fonksiyondan çıkmaya bi yol vermeli
    }

    print("\(number) x \(number) is \(number * number)")
}

/////
func getMeaningOfLife() -> Int? {
    42
}

func printMeaningOfLife() {
    if let name = getMeaningOfLife() {
        print(name)
    }
}

func printM() {
    guard let name = getMeaningOfLife() else {
        return
    }
    print(name)
}
