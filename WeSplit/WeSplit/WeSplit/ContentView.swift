//
//  ContentView.swift
//  WeSplit
//
//  Created by Mehmet Ataman on 6.05.2026.
//

import SwiftUI

struct ContentView: View {
    let students = ["Harry", "Hermione", "Ron", "Draco"]
    @State private var selectedStudent = "Harry"
    
    var body: some View {
        NavigationStack{
            Form {
                Picker("Select your student", selection: $selectedStudent) {
                    ForEach(students, id: \.self) {
                        Text($0)
                    }
                }
            }
            .navigationBarTitle("Select a Student")
        }
    }
}

#Preview {
    ContentView()
}
