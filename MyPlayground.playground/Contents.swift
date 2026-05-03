import Cocoa

class User {
    var username = "Anonymous"
}

var user1 = User()
user1.username = "Foo"

var user2 = user1
user2.username = "Bar"

print(user1.username)
print(user2.username)

// burada user1 User class'ından bir nesne oluşturdu ve username'i "Foo" yaptı.
// user2 = user1 dediğimizde yeni bir kopya oluşmadı, aynı User nesnesine referans verildi.
// bu yüzden user2 üzerinden yapılan değişiklik (username = "Bar"), aslında aynı nesne üzerinde gerçekleşti.
// dolayısıyla hem user1 hem user2 için username "Bar" olarak göründü.

// _________________

// eğer struct kullansaydık bunlar ayrı olurdu, çünkü struct'ta referans alınmıyor, kopya oluşturuluyor.

struct UserX {
    var username = "Anonymous"
}

var user1x = UserX()
user1x.username = "Foo"

var user2x = user1x
user2x.username = "Bar"

print(user1x.username)
print(user2x.username)

//

class UserCustom {
    var username = "Anonymous"
    
    func copy() -> UserCustom {
        let user = UserCustom()
        user.username = username
        return user
    }
}

var user3 = UserCustom()
user3.username = "Foo"

var user4 = user3.copy()
user4.username = "Mehmet"
print(user4.username)
print(user3.username)
