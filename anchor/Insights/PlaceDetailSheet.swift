//
//  PlaceDetailSheet.swift
//  anchor
//

import SwiftData
import SwiftUI

struct PlaceDetailSheet: View {
    let place: FocusPlace

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var draftName = ""

    var body: some View {
        ZStack {
            CanvasBackground()

            VStack(alignment: .leading, spacing: 24) {
                nameField

                HStack(spacing: 12) {
                    stat(value: "\(place.sessionCount)", label: "Sessions")
                    stat(value: totalFocus, label: "Total focus")
                }

                if let last = place.lastSessionAt {
                    Text("Last session \(last, format: .dateTime.weekday(.wide).month().day())")
                        .font(.system(size: 13))
                        .foregroundStyle(Colors.onCanvas.opacity(0.7))
                }

                Spacer()

                Button("Done") { save() }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Colors.ink)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.white, in: Capsule())
                    .buttonStyle(.plain)
            }
            .padding(24)
        }
        .presentationDetents([.medium])
        .onAppear { draftName = place.name }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NAME")
                .font(.system(size: 11, weight: .bold))
                .tracking(1)
                .foregroundStyle(Colors.onCanvas.opacity(0.6))

            TextField("Name", text: $draftName)
                .font(.system(size: 26, weight: .heavy))
                .tracking(-0.8)
                .foregroundStyle(Colors.onCanvas)
                .textFieldStyle(.plain)
                .submitLabel(.done)
                .onSubmit(save)
        }
    }

    private func stat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 26, weight: .bold))
                .tracking(-0.6)
                .foregroundStyle(Colors.textPrimary)

            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Colors.textSecondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var totalFocus: String {
        let minutes = Int(place.totalFocusSeconds / 60)
        return minutes >= 60 ? "\(minutes / 60)h \(minutes % 60)m" : "\(minutes)m"
    }

    /// A name the user typed is theirs to keep — `isUserNamed` is what stops a
    /// later lookup from quietly renaming it back.
    private func save() {
        let trimmed = draftName.trimmingCharacters(in: .whitespaces)

        if !trimmed.isEmpty, trimmed != place.name {
            place.name = trimmed
            place.isUserNamed = true
            place.updatedAt = .now
            try? context.save()
        }

        dismiss()
    }
}
