//
//  ContentView.swift
//  Conversion
//
//  Created by Mehmet Ataman on 8.05.2026.
//

import SwiftUI

struct ContentView: View {
    let drugNames = ["Nöradrenalin", "Adrenalin", "Dobutamin"]
    @State private var selectedDrug: String = "Nöradrenalin"
    @State private var medicationDosageMg = 8.0
    @State private var solutionVolumeMl = 100.0
    @State private var weight = 70.0
    @State private var infusionRatePerHour = 3.0
    var concentrationMcgPerML: Double { (medicationDosageMg * 1000 / solutionVolumeMl)}
    var infusionRatePerMinute: Double { (infusionRatePerHour / 60)}
    var doseMcgKgMin: Double { (concentrationMcgPerML * infusionRatePerMinute) / weight}
    
    var body: some View {
        VStack {
            Text("İlaç seçenekleri")
            Picker("İlaç seç", selection: $selectedDrug) {
                ForEach(drugNames, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
            Form {
                TextField("İlaç miktarı (mg)", value: $medicationDosageMg, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                TextField("Çözücü miktarı (ml)", value: $solutionVolumeMl, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                TextField("Kilo (kg)", value: $weight, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                TextField("Hız (cc/h)", value: $infusionRatePerHour, formatter: NumberFormatter())
                    .keyboardType(.decimalPad)
                Section {
                    Text("mcg/kg/dk: \(doseMcgKgMin)")
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
