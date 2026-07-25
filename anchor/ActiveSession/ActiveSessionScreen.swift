//
//  ActiveSessionScreen.swift
//  anchor
//

import SwiftUI

struct ActiveSessionScreen: View {
    @Environment(\.dismiss) private var dismiss
    @State private var startDate = Date.now

    private var elapsed: TimeInterval {
        Date.now.timeIntervalSince(startDate)
    }

    var body: some View {
        ZStack {
            CanvasBackground()

            VStack(spacing: 0) {
                Spacer()

                Text("Focusing")
                    .font(.system(size: 15, weight: .bold))
                    .tracking(0.4)
                    .foregroundStyle(Colors.onCanvas.opacity(0.7))

                Text(
                    timerInterval: startDate...startDate.addingTimeInterval(86_400),
                    countsDown: false
                )
                .font(.system(size: 68, weight: .heavy))
                .tracking(-2)
                .foregroundStyle(Colors.onCanvas)
                .padding(.top, 10)

                Text("Started \(startDate, format: .dateTime.hour().minute())")
                    .font(.system(size: 14))
                    .foregroundStyle(Colors.onCanvas.opacity(0.6))
                    .padding(.top, 12)

                Spacer()

                Button(action: endSession) {
                    Text("End session")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(Colors.ink)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background(Color.white, in: Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
    }

    private func endSession() {
        // TODO: persist the finished session `elapsed` is its length.
        _ = elapsed
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ActiveSessionScreen()
    }
}
