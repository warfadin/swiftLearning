// nil coalescing

let captains = [
    "Enterprise": "Picard",
    "Voyager": "Janeway",
    "Defiant": "Sisko"
]

let new = captains["Serenity"] ?? "Unassigned" // nil coalescing burada eğer unWrap yaptıktan sonra nil bulursa default bir value atıyor.

let new2 = captains["Serenity", default: "N/A"] // bu da yukarıdaki satırla aslında aynı işi yapar.

let tvShows = ["Enterprise", "Voyager", "Defiant", "Discovery", "Enterprise: The Next Generation"]
let favorite = tvShows.randomElement() ?? "N/A"



