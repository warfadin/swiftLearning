// Optional chaining

let names = ["Arya", "Bran", "Robb", "Sansa"]

let chosen = names.randomElement()?.uppercased() ?? "No one"
print("Next in line: \(chosen)")


struct Book {
    let title: String
    let author: String?
}

var book: Book? = Book(title: "A Song of Ice and Fire", author: "George R.R. Martin")
var book2: Book? = nil
let author = book?.author?.first?.uppercased() ?? "anonymous"
print(author)

let author1=book2?.author?.first?.uppercased() ?? "anonymous"
print(author1)
