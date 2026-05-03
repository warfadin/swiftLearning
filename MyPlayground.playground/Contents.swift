import Cocoa
// DEINITIALIZER mevzusu

// deneitializerler'ın başına func yazılmaz, parametre almazlar veya herhangi bi data return etmezler
// deinit'ler class instance'ın son kopyası yokedildiğinde çalışır
// deinit'ler direkt olarak çağrılmaz
// struct'ların deinit'i olmaz çünkü hepsi unique'tir.


class User {
    let id: Int

    init(id: Int) {
        self.id = id
        print("User \(id): I'm alive!")
    }

    deinit {
        print("User \(id): I'm dead!")
    }
}
var users = [User]()
for i in 1...3 {
    let user = User(id: i)
    users.append(user)
}

print("Loop is finished now!")
users.removeAll()
print("Array is clear")

