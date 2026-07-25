//
//  StartSessionScreen.swift
//  anchor
//

import SwiftUI

struct StartSessionScreen: View {
    let duration: Int

    var body: some View {
        ZStack {
            Colors.background
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Image(systemName: "timer.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Colors.primary)

                Text("\(duration) minutes")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .foregroundStyle(Colors.textPrimary)

                Text("Session setup is the next feature. The Home UI passes the selected duration here without knowing how sessions are stored.")
                    .font(.subheadline)
                    .foregroundStyle(Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 320)
            }
            .padding(24)
        }
        .navigationTitle("New Session")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        StartSessionScreen(duration: 25)
    }
    .preferredColorScheme(.dark)
}
