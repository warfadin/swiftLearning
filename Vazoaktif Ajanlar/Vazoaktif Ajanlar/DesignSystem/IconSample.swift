//
//  IconSample.swift
//  Vazoaktif Ajanlar
//
//  Created by Mehmet Ataman on 9.05.2026.
//


struct IconSample: View {
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color.blue, Color.white], startPoint: .top, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 22))
            VStack(spacing: 0) {
                Image(systemName: "drop.fill") // Damla
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                Image(systemName: "heart.fill") // Kalp
                    .font(.system(size: 22))
                    .foregroundColor(.red)
                    .offset(y: -30)
                Rectangle() // Slider göstergesi
                    .frame(width: 40, height: 4)
                    .cornerRadius(2)
                    .foregroundColor(.orange)
                    .offset(y: -10)
            }
        }
        .frame(width: 120, height: 120)
        .shadow(radius: 8)
    }
}