//  FoodMenuView.swift
//  Vazoaktif Ajanlar
//
//  Created by Mehmet Ataman on 10.05.2026.
//
import SwiftUI

struct FoodMenuView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var camlikMenu: CanteenMenu?
    @State private var selectedDate = Date()
    @State private var selectedMode: FoodMenuMode = .day
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var hasLoaded = false

    private let service: FoodMenuService
    private let calendar = Calendar.current

    init(service: FoodMenuService = FoodMenuService()) {
        self.service = service
    }

    private var isDarkMode: Bool {
        colorScheme == .dark
    }

    private var sortedDays: [DailyCanteenMenu] {
        camlikMenu?.days.sorted { $0.date < $1.date } ?? []
    }

    var body: some View {
        ZStack {
            AppColors.background(isDarkMode).ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    header
                    modePicker
                    content
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle("Yemek Menüsü")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Bugün") {
                    selectToday()
                }
            }
        }
        .task {
            guard !hasLoaded else {
                return
            }

            hasLoaded = true
            await loadMenu()
        }
        .refreshable { await loadMenu(forceRemote: true) }
    }

    private var header: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Çamlık")
                    .font(.system(size: 34, weight: .heavy, design: .rounded))
                    .foregroundStyle(.green)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("Yemek menüsü")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppColors.primaryText(isDarkMode))
            }

            Spacer()

            AppThemeControl()
        }
    }

    private var modePicker: some View {
        Picker("Görünüm", selection: $selectedMode) {
            ForEach(FoodMenuMode.allCases) { mode in
                Text(mode.title).tag(mode)
            }
        }
        .pickerStyle(.segmented)
    }

    @ViewBuilder
    private var content: some View {
        if isLoading, camlikMenu == nil {
            statusPanel(
                systemImage: "fork.knife",
                title: "Menü yükleniyor",
                message: "Uludağ Üniversitesi yemek sayfası kontrol ediliyor."
            )
        } else if let errorMessage, camlikMenu == nil {
            errorPanel(errorMessage)
        } else if sortedDays.isEmpty {
            statusPanel(
                systemImage: "calendar.badge.exclamationmark",
                title: "Menü bulunamadı",
                message: "Kayıtlı aylık Çamlık menüsünde gösterilecek gün bulunamadı."
            )
        } else {
            switch selectedMode {
            case .day:
                dailyPager
            case .month:
                monthList
            }
        }
    }

    private var dailyPager: some View {
        TabView(selection: $selectedDate) {
            ForEach(sortedDays) { day in
                ScrollView {
                    dailyCard(day)
                        .padding(.bottom, 28)
                }
                .refreshable { await loadMenu(forceRemote: true) }
                .tag(day.date)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(minHeight: 560)
        .animation(.easeInOut(duration: 0.2), value: selectedDate)
    }

    private var monthList: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Ay")
                .font(.headline.weight(.heavy))
                .foregroundStyle(AppColors.primaryText(isDarkMode))

            ForEach(sortedDays) { day in
                compactDayCard(day)
            }
        }
    }

    private func dailyCard(_ day: DailyCanteenMenu) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            dayHeader(day, titleFont: .title3.weight(.heavy))

            if day.isClosed {
                closedPanel(for: day)
            } else {
                mealSection(title: "Öğle Yemeği", items: visibleMealItems(day.lunch))
                if !visibleMealItems(day.ordovr).isEmpty {
                    mealSection(title: "Ordövr", items: visibleMealItems(day.ordovr))
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(AppColors.panel(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
        .overlay(alignment: .topTrailing) {
            if isLoading {
                ProgressView()
                    .padding(14)
            }
        }
    }

    private func compactDayCard(_ day: DailyCanteenMenu) -> some View {
        let lunch = visibleMealItems(day.lunch)
        let ordovr = visibleMealItems(day.ordovr)

        return Button {
            selectedDate = day.date
            selectedMode = .day
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                dayHeader(day, titleFont: .headline.weight(.heavy))

                if day.isClosed {
                    Text("Kapalı")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.secondary)
                } else {
                    if !lunch.isEmpty {
                        compactMealPreview(title: "Öğle", items: lunch)
                    }
                    if !ordovr.isEmpty {
                        compactMealPreview(title: "Ordövr", items: ordovr)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.panel(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }

    private func dayHeader(_ day: DailyCanteenMenu, titleFont: Font) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(day.dayMonthText)
                .font(titleFont)
                .foregroundStyle(AppColors.primaryText(isDarkMode))

            Text(day.weekday)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondary)

            Spacer()

            if calendar.isDateInToday(day.date) {
                Text("Bugün")
                    .font(.caption.weight(.heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.green, in: RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func compactMealPreview(title: String, items: [MealItem]) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(title)
                .font(.caption.weight(.heavy))
                .foregroundStyle(.green)
                .frame(width: 52, alignment: .leading)

            Text(items.map(\.displayName).joined(separator: ", "))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.primaryText(isDarkMode))
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func closedPanel(for day: DailyCanteenMenu) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.green)

            Text(calendar.isDateInToday(day.date) ? "Çamlık yemekhanesi bugün kapalı." : "Çamlık yemekhanesi kapalı.")
                .font(.body.weight(.semibold))
                .foregroundStyle(AppColors.primaryText(isDarkMode))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(AppColors.controlBackground(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
    }

    private func mealSection(title: String, items: [MealItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline.weight(.heavy))
                .foregroundStyle(AppColors.primaryText(isDarkMode))

            if items.isEmpty {
                Text("Bugün için kayıt görünmüyor.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(AppColors.controlBackground(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
            } else {
                VStack(spacing: 8) {
                    ForEach(items) { item in
                        HStack(spacing: 10) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 7))
                                .foregroundStyle(.green)

                            Text(item.displayName)
                                .font(.body.weight(.semibold))
                                .foregroundStyle(AppColors.primaryText(isDarkMode))
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(12)
                        .background(AppColors.controlBackground(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }

    private func statusPanel(systemImage: String, title: String, message: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(.green)

            Text(title)
                .font(.headline.weight(.heavy))
                .foregroundStyle(AppColors.primaryText(isDarkMode))

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(AppColors.panel(isDarkMode), in: RoundedRectangle(cornerRadius: 8))
    }

    private func errorPanel(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            statusPanel(
                systemImage: "exclamationmark.triangle.fill",
                title: "Menü alınamadı",
                message: message
            )

            Button {
                Task {
                    await loadMenu(forceRemote: true)
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Tekrar dene")
                }
                .font(.subheadline.weight(.bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .background(.green, in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private func selectToday() {
        selectedMode = .day

        if let today = camlikMenu?.menu(for: Date()) {
            selectedDate = today.date
        } else {
            selectedDate = Date()
        }
    }

    private func visibleMealItems(_ items: [MealItem]) -> [MealItem] {
        items.filter { !$0.displayName.isEmpty && !$0.isAllergenOnly }
    }

    @MainActor
    private func loadMenu(forceRemote: Bool = false) async {
        isLoading = true
        errorMessage = nil

        do {
            let menu = try await service.fetchMonthlyCamlikMenu(forceRemote: forceRemote)
            camlikMenu = menu
            selectedDate = menu.menu(for: selectedDate)?.date
                ?? menu.menu(for: Date())?.date
                ?? menu.days.first?.date
                ?? selectedDate
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }

        isLoading = false
    }
}

#Preview {
    FoodMenuView()
}

private enum FoodMenuMode: String, CaseIterable, Identifiable {
    case day
    case month

    var id: Self { self }

    var title: String {
        switch self {
        case .day:
            "Gün"
        case .month:
            "Ay"
        }
    }
}

private extension DailyCanteenMenu {
    var dayMonthText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "tr_TR")
        formatter.dateFormat = "d MMMM"
        return formatter.string(from: date)
    }
}

private extension MealItem {
    var displayName: String {
        name
            .replacingOccurrences(of: #"\s*\(\s*\d+(\s*,\s*\d+)*\s*\)\s*$"#, with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isAllergenOnly: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedName.hasPrefix("Alerjen içeriği:") {
            return true
        }

        return trimmedName.range(of: #"^\(?\s*\d+(\s*,\s*\d+)*\s*\)?$"#, options: .regularExpression) != nil
    }
}
