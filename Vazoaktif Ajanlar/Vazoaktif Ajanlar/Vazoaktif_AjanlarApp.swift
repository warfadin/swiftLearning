import SwiftUI

@main
struct VasoactiveCalculatorApp: App {
    var body: some Scene {
        WindowGroup {
            VasoactiveCalculatorView()
        }
    }
}

struct VasoactiveCalculatorView: View {
    @State private var selectedAgent: VasoactiveAgent = .norepinephrine
    @State private var selectedPresetID: String = VasoactiveAgent.norepinephrine.presets[0].id
    @State private var weightKg = 70
    @State private var dose: Double = 0.08
    @State private var showsManualMix = false
    @State private var manualDrugMg = "8"
    @State private var manualVolumeMl = "100"
    @State private var isDarkMode = false

    private var activePreset: InfusionPreset {
        if showsManualMix, let manualPreset {
            return manualPreset
        }

        return selectedAgent.presets.first { $0.id == selectedPresetID } ?? selectedAgent.presets[0]
    }

    private var manualPreset: InfusionPreset? {
        guard
            let mg = Double(manualDrugMg.replacingOccurrences(of: ",", with: ".")),
            let ml = Double(manualVolumeMl.replacingOccurrences(of: ",", with: ".")),
            mg > 0,
            ml > 0
        else { return nil }

        return InfusionPreset(name: "Manuel", drugMg: mg, volumeMl: ml)
    }

    private var infusionRate: Double {
        dose * Double(weightKg) * 60 / activePreset.concentrationMcgPerMl
    }

    private var doseRange: ClosedRange<Double> {
        0...selectedAgent.sliderMaxDose(for: activePreset, weightKg: weightKg)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background(isDarkMode).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 14) {
                        header
                        agentPicker
                        patientAndPresetPanel
                        dosePanel
                        clinicalNotePanel
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onChange(of: selectedAgent) { _, newAgent in
                selectedPresetID = newAgent.presets[0].id
                dose = min(newAgent.startingDose, newAgent.sliderMaxDose(for: newAgent.presets[0], weightKg: weightKg))
                showsManualMix = false
                manualDrugMg = cleanNumber(newAgent.presets[0].drugMg)
                manualVolumeMl = cleanNumber(newAgent.presets[0].volumeMl)
            }
            .onChange(of: weightKg) { _, _ in
                dose = min(dose, doseRange.upperBound)
            }
            .onChange(of: activePreset.id) { _, _ in
                dose = min(dose, doseRange.upperBound)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Vazoaktif Ajan Hesaplayıcı")
                    .font(.headline.weight(.bold))
                Text(selectedAgent.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                isDarkMode.toggle()
            } label: {
                Image(systemName: isDarkMode ? "moon.fill" : "sun.max.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(isDarkMode ? .yellow : .orange)
                    .background(.thinMaterial, in: Circle())
            }
            .accessibilityLabel(isDarkMode ? "Açık tema" : "Koyu tema")
        }
    }

    private var agentPicker: some View {
        HStack(spacing: 8) {
            ForEach(VasoactiveAgent.allCases) { agent in
                Button {
                    selectedAgent = agent
                } label: {
                    Text(agent.shortName)
                        .font(.subheadline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .frame(height: 42)
                        .foregroundStyle(selectedAgent == agent ? .white : AppColors.primaryText(isDarkMode))
                        .background(selectedAgent == agent ? agent.color : AppColors.controlBackground(isDarkMode))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(agent.displayName)
            }
        }
    }

    private var patientAndPresetPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Kilo")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)

                    Menu {
                        ForEach(Array(stride(from: 30, through: 180, by: 5)), id: \.self) { kg in
                            Button("\(kg) kg") { weightKg = kg }
                        }
                    } label: {
                        HStack {
                            Text("\(weightKg) kg")
                                .font(.title3.weight(.bold))
                            Image(systemName: "chevron.down")
                                .font(.caption.weight(.bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 11)
                        .padding(.horizontal, 12)
                        .background(AppColors.controlBackground(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .foregroundStyle(AppColors.primaryText(isDarkMode))
                }

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Presetler")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        Button {
                            showsManualMix.toggle()
                        } label: {
                            Image(systemName: showsManualMix ? "slider.horizontal.3" : "pencil.line")
                                .frame(width: 32, height: 32)
                        }
                        .buttonStyle(.bordered)
                        .tint(selectedAgent.color)
                        .accessibilityLabel("Manuel ayarla")
                    }

                    Picker("Preset", selection: $selectedPresetID) {
                        ForEach(selectedAgent.presets) { preset in
                            Text(preset.name).tag(preset.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AppColors.controlBackground(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
                }
            }

            if showsManualMix {
                manualMixEditor
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(AppColors.panel(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
    }

    private var manualMixEditor: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Manuel karışım")
                .font(.caption.weight(.bold))
                .foregroundStyle(.secondary)

            HStack(spacing: 10) {
                numericField(title: "İlaç", value: $manualDrugMg, suffix: "mg")
                numericField(title: "Sıvı", value: $manualVolumeMl, suffix: "mL")
            }

            Text("Konsantrasyon: \(activePreset.concentrationMcgPerMl, specifier: "%.1f") mcg/mL")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(AppColors.controlBackground(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
    }

    private func numericField(title: String, value: Binding<String>, suffix: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(.secondary)

            HStack(spacing: 6) {
                TextField("0", text: value)
                    .font(.body.weight(.bold))
                    .decimalKeyboard()
                Text(suffix)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .frame(height: 42)
            .background(AppColors.fieldBackground(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private var dosePanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Doz")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                    Text("\(dose, specifier: "%.3f") mcg/kg/dk")
                        .font(.title2.weight(.heavy))
                        .foregroundStyle(selectedAgent.color)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(selectedAgent.intensity(for: dose).label)
                        .font(.caption.weight(.heavy))
                        .foregroundStyle(selectedAgent.intensity(for: dose).color)
                    Text("\(infusionRate, specifier: "%.1f") cc/h")
                        .font(.title2.weight(.heavy))
                }
            }

            GradientDoseSlider(
                value: $dose,
                range: doseRange,
                intensity: selectedAgent.intensity(for: dose)
            )
            .frame(height: 44)

            HStack {
                Text("0")
                Spacer()
                Text("\(doseRange.upperBound, specifier: selectedAgent == .dopamine || selectedAgent == .dobutamine ? "%.0f" : "%.2f")")
            }
            .font(.caption2.weight(.bold))
            .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                Text(selectedAgent.effectText(for: dose))
                    .font(.callout.weight(.bold))
                    .foregroundStyle(AppColors.primaryText(isDarkMode))

                Text(selectedAgent.recommendation(for: dose, rate: infusionRate))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.controlBackground(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
        }
        .padding(14)
        .background(AppColors.panel(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
    }

    private var clinicalNotePanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: selectedAgent == .dopamine ? "exclamationmark.triangle.fill" : "info.circle.fill")
                    .foregroundStyle(selectedAgent == .dopamine ? .orange : selectedAgent.color)

                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedAgent == .dopamine ? "Dopamin uyarısı" : "Klinik not")
                        .font(.caption.weight(.heavy))

                    Text(selectedAgent.clinicalNote)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.panel(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
    }
}

struct GradientDoseSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let intensity: DoseIntensity

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let progress = normalizedProgress
            let thumbX = max(14, min(width - 14, progress * width))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [.green, .yellow, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 12)
                    .opacity(0.95)

                Capsule()
                    .fill(.black.opacity(0.10))
                    .frame(height: 12)

                Circle()
                    .fill(intensity.color)
                    .frame(width: 30, height: 30)
                    .overlay(Circle().stroke(.white, lineWidth: 3))
                    .shadow(color: .black.opacity(0.18), radius: 5, y: 2)
                    .offset(x: thumbX - 15)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let clampedX = min(max(gesture.location.x, 0), width)
                        value = range.lowerBound + (clampedX / width) * (range.upperBound - range.lowerBound)
                    }
            )
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Doz slider")
        .accessibilityValue("\(value, specifier: "%.3f") mcg/kg/dk")
    }

    private var normalizedProgress: Double {
        guard range.upperBound > range.lowerBound else { return 0 }
        return (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }
}

enum VasoactiveAgent: String, CaseIterable, Identifiable {
    case norepinephrine
    case adrenaline
    case dobutamine
    case dopamine

    var id: String { rawValue }

    var shortName: String {
        switch self {
        case .norepinephrine: "NA"
        case .adrenaline: "A"
        case .dobutamine: "Dob"
        case .dopamine: "Dop"
        }
    }

    var displayName: String {
        switch self {
        case .norepinephrine: "Nöradrenalin"
        case .adrenaline: "Adrenalin"
        case .dobutamine: "Dobutamin"
        case .dopamine: "Dopamin"
        }
    }

    var color: Color {
        switch self {
        case .norepinephrine: .blue
        case .adrenaline: .pink
        case .dobutamine: .purple
        case .dopamine: .orange
        }
    }

    var startingDose: Double {
        switch self {
        case .norepinephrine: 0.08
        case .adrenaline: 0.04
        case .dobutamine: 5
        case .dopamine: 5
        }
    }

    var presets: [InfusionPreset] {
        switch self {
        case .norepinephrine:
            [
                InfusionPreset(name: "8 mg / 100 mL SF", drugMg: 8, volumeMl: 100),
                InfusionPreset(name: "16 mg / 100 mL SF", drugMg: 16, volumeMl: 100),
                InfusionPreset(name: "4 mg / 50 mL SF", drugMg: 4, volumeMl: 50),
                InfusionPreset(name: "32 mg / 250 mL SF", drugMg: 32, volumeMl: 250)
            ]
        case .adrenaline:
            [
                InfusionPreset(name: "4 mg / 100 mL SF", drugMg: 4, volumeMl: 100),
                InfusionPreset(name: "8 mg / 100 mL SF", drugMg: 8, volumeMl: 100),
                InfusionPreset(name: "4 mg / 50 mL SF", drugMg: 4, volumeMl: 50),
                InfusionPreset(name: "10 mg / 250 mL SF", drugMg: 10, volumeMl: 250)
            ]
        case .dobutamine:
            [
                InfusionPreset(name: "250 mg / 250 mL D5W", drugMg: 250, volumeMl: 250),
                InfusionPreset(name: "500 mg / 250 mL D5W", drugMg: 500, volumeMl: 250),
                InfusionPreset(name: "250 mg / 50 mL D5W", drugMg: 250, volumeMl: 50),
                InfusionPreset(name: "500 mg / 500 mL D5W", drugMg: 500, volumeMl: 500)
            ]
        case .dopamine:
            [
                InfusionPreset(name: "400 mg / 250 mL D5W", drugMg: 400, volumeMl: 250),
                InfusionPreset(name: "800 mg / 250 mL D5W", drugMg: 800, volumeMl: 250),
                InfusionPreset(name: "200 mg / 100 mL D5W", drugMg: 200, volumeMl: 100),
                InfusionPreset(name: "400 mg / 500 mL D5W", drugMg: 400, volumeMl: 500)
            ]
        }
    }

    func sliderMaxDose(for preset: InfusionPreset, weightKg: Int) -> Double {
        let practicalDoseAt30cc = 30 * preset.concentrationMcgPerMl / (Double(weightKg) * 60)

        switch self {
        case .norepinephrine:
            return max(0.8, min(1.5, practicalDoseAt30cc * 2.1))
        case .adrenaline:
            return max(0.6, min(1.2, practicalDoseAt30cc * 2.0))
        case .dobutamine:
            return 25
        case .dopamine:
            return 25
        }
    }

    func intensity(for dose: Double) -> DoseIntensity {
        switch self {
        case .norepinephrine:
            if dose < 0.1 { return .low }
            if dose < 0.3 { return .medium }
            return .high
        case .adrenaline:
            if dose < 0.05 { return .low }
            if dose < 0.2 { return .medium }
            return .high
        case .dobutamine:
            if dose < 5 { return .low }
            if dose <= 10 { return .medium }
            return .high
        case .dopamine:
            if dose < 5 { return .low }
            if dose < 10 { return .medium }
            return .high
        }
    }

    func effectText(for dose: Double) -> String {
        switch self {
        case .norepinephrine:
            if dose < 0.1 { return "Düşük doz: baskın alfa vazokonstriksiyon, MAP desteği." }
            if dose < 0.3 { return "Orta doz: güçlü vazopressör etki, perfüzyon ve laktat yakın izlenmeli." }
            return "Yüksek doz: belirgin vazopressör gereksinimi, ek ajan ve şok nedeni yeniden değerlendirilmeli."
        case .adrenaline:
            if dose < 0.05 { return "Düşük doz: beta-1 inotrop/kronotrop etki belirginleşir." }
            if dose < 0.2 { return "Orta doz: inotropi ile birlikte alfa vazopressör etki artar." }
            return "Yüksek doz: alfa vazokonstriksiyon, taşiaritmi ve laktat artışı açısından dikkat."
        case .dobutamine:
            if dose < 3 { return "Düşük doz: hafif beta-1 inotrop etki." }
            if dose <= 10 { return "3-10 mcg/kg/dk: baskın inotrop etki, kardiyak debi desteği." }
            if dose <= 20 { return "15-20 mcg/kg/dk: inotrop etkiye ek vazopressör/taşikardik yanıt görülebilir." }
            return "Çok yüksek doz: aritmi, iskemi ve hipotansiyon açısından dikkat."
        case .dopamine:
            if dose < 3 { return "Düşük doz: dopaminerjik etki; renal koruma amacıyla kullanımı önerilmez." }
            if dose < 10 { return "Orta doz: beta-1 inotrop/kronotrop etki baskın." }
            return "Yüksek doz: alfa vazopressör etki, taşiaritmi riski artar."
        }
    }

    func recommendation(for dose: Double, rate: Double) -> String {
        switch self {
        case .norepinephrine:
            if dose >= 0.25 {
                return "MAP yetersizse norepinefrini sürekli artırmak yerine vazopressin eklenmesi klinik olarak değerlendirilebilir."
            }
            if rate > 30 {
                return "Bu karışım ve kiloda hız 30 cc/h üstüne çıktı; daha konsantre karışım veya ek ajan ihtiyacı değerlendirilebilir."
            }
            return "Ekstravazasyon, periferik dolaşım ve hedef MAP düzenli izlenmeli."
        case .adrenaline:
            if dose >= 0.2 {
                return "Taşikardi, aritmi, laktat yükselmesi ve miyokardiyal iskemi açısından yakın izlem gerekir."
            }
            return "Şok tipine göre inotrop/vazopressör hedef yeniden değerlendirilmelidir."
        case .dobutamine:
            if dose >= 10 {
                return "Yüksek dozlarda taşikardi, aritmi ve hipotansiyon gelişebilir; volüm durumu ve vazopressör ihtiyacı kontrol edilmeli."
            }
            return "Kardiyak debi, kan basıncı ve ritim yanıtına göre titre edilir."
        case .dopamine:
            return "Sepsiste ilk seçenek değildir; aritmi riski ve norepinefrin erişimi özellikle değerlendirilmelidir."
        }
    }

    var clinicalNote: String {
        switch self {
        case .norepinephrine:
            "Sepsiste ilk basamak vazopressör olarak norepinefrin önerilir. Preset ve limitler kurum protokolüyle doğrulanmalıdır."
        case .adrenaline:
            "Norepinefrin ve vazopressin sonrası yetersiz MAP durumunda ek ajan olarak değerlendirilebilir."
        case .dobutamine:
            "Düşük kardiyak debi veya miyokard disfonksiyonu düşünüldüğünde, kan basıncı ve ritim izlemiyle titre edilir."
        case .dopamine:
            "Dopaminin vazoaktif olarak kullanımı güncel sepsis kılavuzlarında rutin olarak önerilmez. Bkz: Surviving Sepsis Campaign Guidelines, 2021."
        }
    }
}

struct InfusionPreset: Identifiable, Equatable {
    let name: String
    let drugMg: Double
    let volumeMl: Double

    var id: String { "\(name)-\(drugMg)-\(volumeMl)" }
    var concentrationMcgPerMl: Double { drugMg * 1000 / volumeMl }
}

enum DoseIntensity {
    case low
    case medium
    case high

    var label: String {
        switch self {
        case .low: "Düşük doz"
        case .medium: "Orta doz"
        case .high: "Yüksek doz"
        }
    }

    var color: Color {
        switch self {
        case .low: .green
        case .medium: .yellow
        case .high: .red
        }
    }
}

enum AppColors {
    static func background(_ dark: Bool) -> Color {
        dark ? Color(red: 0.06, green: 0.07, blue: 0.09) : Color(red: 0.95, green: 0.97, blue: 0.98)
    }

    static func panel(_ dark: Bool) -> Color {
        dark ? Color(red: 0.11, green: 0.12, blue: 0.15) : .white
    }

    static func controlBackground(_ dark: Bool) -> Color {
        dark ? Color(red: 0.16, green: 0.17, blue: 0.21) : Color(red: 0.91, green: 0.94, blue: 0.96)
    }

    static func fieldBackground(_ dark: Bool) -> Color {
        dark ? Color(red: 0.08, green: 0.09, blue: 0.12) : .white
    }

    static func primaryText(_ dark: Bool) -> Color {
        dark ? .white : Color(red: 0.08, green: 0.10, blue: 0.13)
    }
}

private func cleanNumber(_ value: Double) -> String {
    value.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(value)) : String(value)
}

private extension View {
    @ViewBuilder
    func decimalKeyboard() -> some View {
        #if os(iOS)
        self.keyboardType(.decimalPad)
        #else
        self
        #endif
    }
}

struct VasoactiveCalculatorView_Previews: PreviewProvider {
    static var previews: some View {
        VasoactiveCalculatorView()
    }
}
