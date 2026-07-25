//
//  CanvasBackground.swift
//  anchor
//

import SwiftUI

struct CanvasBackground: View {
    var body: some View {
        Colors.canvas
            .overlay {
                Canvas { context, size in
                    // Anchored off-screen top-left so the rings read as a
                    // fragment of a much larger survey, not a bullseye.
                    let center = CGPoint(x: size.width * 0.22, y: size.height * 0.16)
                    let maxRadius = max(size.width, size.height) * 1.6

                    var radius = 46.0
                    var ring = 0

                    while radius < maxRadius {
                        context.stroke(
                            contour(center: center, radius: radius, ring: ring),
                            with: .color(Colors.canvasLine),
                            lineWidth: 1.4
                        )
                        radius += 38
                        ring += 1
                    }
                }
                .allowsHitTesting(false)
            }
            .ignoresSafeArea()
    }

    private func contour(center: CGPoint, radius: Double, ring: Int) -> Path {
        let phase = Double(ring) * 0.55
        let wobble = radius * 0.06

        var path = Path()
        let steps = 90

        for step in 0...steps {
            let angle = Double(step) / Double(steps) * 2 * .pi
            let r = radius
                + sin(angle * 3 + phase) * wobble
                + sin(angle * 5 - phase * 1.7) * wobble * 0.45

            let point = CGPoint(
                x: center.x + cos(angle) * r,
                y: center.y + sin(angle) * r
            )

            step == 0 ? path.move(to: point) : path.addLine(to: point)
        }

        path.closeSubpath()
        return path
    }
}

#Preview {
    CanvasBackground()
}
