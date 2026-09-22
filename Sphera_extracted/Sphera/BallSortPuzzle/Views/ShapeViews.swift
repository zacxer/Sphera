//
//  ShapeViews.swift
//  BallSortPuzzle
//
//  Created on 2026-01-03.
//  FASE 3: Viste per tutte le forme geometriche
//

import SwiftUI

// MARK: - Cube Shape View

struct CubeShapeView: View {
    let color: BallColor
    let size: CGFloat

    var body: some View {
        ZStack {
            // Ombra
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(color.shadowColor)
                .frame(width: size * 0.85, height: size * 0.85)
                .blur(radius: 4)
                .offset(x: 2, y: 4)

            // Glow colorato
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(color.color.opacity(0.5))
                .frame(width: size * 0.9, height: size * 0.9)
                .blur(radius: 8)

            // Faccia principale
            RoundedRectangle(cornerRadius: size * 0.2)
                .fill(
                    LinearGradient(
                        colors: [
                            color.highlightColor,
                            color.color,
                            color.shadowColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.85, height: size * 0.85)

            // Bordo 3D - lato superiore (più chiaro)
            Path { path in
                let s = size * 0.85
                let corner = s * 0.15
                let offset = (size - s) / 2
                path.move(to: CGPoint(x: offset + corner, y: offset + corner))
                path.addLine(to: CGPoint(x: offset, y: offset))
                path.addLine(to: CGPoint(x: offset + s, y: offset))
                path.addLine(to: CGPoint(x: offset + s - corner, y: offset + corner))
                path.closeSubpath()
            }
            .fill(color.highlightColor.opacity(0.6))

            // Bordo 3D - lato destro (più scuro)
            Path { path in
                let s = size * 0.85
                let corner = s * 0.15
                let offset = (size - s) / 2
                path.move(to: CGPoint(x: offset + s - corner, y: offset + corner))
                path.addLine(to: CGPoint(x: offset + s, y: offset))
                path.addLine(to: CGPoint(x: offset + s, y: offset + s))
                path.addLine(to: CGPoint(x: offset + s - corner, y: offset + s - corner))
                path.closeSubpath()
            }
            .fill(color.shadowColor.opacity(0.5))

            // Riflesso
            RoundedRectangle(cornerRadius: size * 0.15)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.7), Color.white.opacity(0.2), .clear],
                        startPoint: .topLeading,
                        endPoint: .center
                    )
                )
                .frame(width: size * 0.4, height: size * 0.4)
                .offset(x: -size * 0.15, y: -size * 0.15)

            // Punto luce
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: size * 0.1, height: size * 0.1)
                .offset(x: -size * 0.25, y: -size * 0.25)

            // Bordo luminoso
            RoundedRectangle(cornerRadius: size * 0.2)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.6),
                            Color.white.opacity(0.1),
                            color.color.opacity(0.3)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: size * 0.85, height: size * 0.85)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Pyramid Shape View

struct PyramidShapeView: View {
    let color: BallColor
    let size: CGFloat

    var body: some View {
        ZStack {
            // Ombra
            PyramidShape()
                .fill(color.shadowColor)
                .frame(width: size * 0.85, height: size * 0.85)
                .blur(radius: 4)
                .offset(y: 3)

            // Glow colorato
            PyramidShape()
                .fill(color.color.opacity(0.5))
                .frame(width: size * 0.9, height: size * 0.9)
                .blur(radius: 8)

            // Faccia sinistra (più scura)
            Path { path in
                let w = size * 0.85
                let h = size * 0.85
                let offsetX = (size - w) / 2
                let offsetY = (size - h) / 2
                path.move(to: CGPoint(x: offsetX + w / 2, y: offsetY))
                path.addLine(to: CGPoint(x: offsetX, y: offsetY + h))
                path.addLine(to: CGPoint(x: offsetX + w / 2, y: offsetY + h * 0.7))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [color.color, color.shadowColor],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Faccia destra (più chiara)
            Path { path in
                let w = size * 0.85
                let h = size * 0.85
                let offsetX = (size - w) / 2
                let offsetY = (size - h) / 2
                path.move(to: CGPoint(x: offsetX + w / 2, y: offsetY))
                path.addLine(to: CGPoint(x: offsetX + w, y: offsetY + h))
                path.addLine(to: CGPoint(x: offsetX + w / 2, y: offsetY + h * 0.7))
                path.closeSubpath()
            }
            .fill(
                LinearGradient(
                    colors: [color.highlightColor, color.color],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            // Bordo luminoso
            PyramidShape()
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.8), color.highlightColor.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1.5
                )
                .frame(width: size * 0.85, height: size * 0.85)

            // Punto luce sulla punta
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.12, height: size * 0.12)
                .offset(y: -size * 0.32)
                .blur(radius: 2)

            // Riflesso laterale
            Ellipse()
                .fill(Color.white.opacity(0.4))
                .frame(width: size * 0.15, height: size * 0.3)
                .offset(x: size * 0.15, y: -size * 0.05)
                .rotationEffect(.degrees(-15))
        }
        .frame(width: size, height: size)
    }
}

struct PyramidShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Star Shape View

struct StarShapeView: View {
    let color: BallColor
    let size: CGFloat

    var body: some View {
        ZStack {
            // Glow esterno intenso
            StarShape(points: 5, innerRatio: 0.4)
                .fill(color.color.opacity(0.4))
                .frame(width: size * 1.1, height: size * 1.1)
                .blur(radius: 10)

            // Ombra
            StarShape(points: 5, innerRatio: 0.4)
                .fill(color.shadowColor)
                .frame(width: size * 0.8, height: size * 0.8)
                .blur(radius: 3)
                .offset(y: 2)

            // Corpo stella
            StarShape(points: 5, innerRatio: 0.4)
                .fill(
                    RadialGradient(
                        colors: [
                            color.highlightColor,
                            color.color,
                            color.shadowColor
                        ],
                        center: UnitPoint(x: 0.35, y: 0.3),
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size * 0.8, height: size * 0.8)

            // Riflesso centrale
            StarShape(points: 5, innerRatio: 0.4)
                .fill(
                    RadialGradient(
                        colors: [Color.white.opacity(0.7), .clear],
                        center: .topLeading,
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.5, height: size * 0.5)
                .offset(x: -size * 0.08, y: -size * 0.08)

            // Punto luce
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.1, height: size * 0.1)
                .offset(x: -size * 0.12, y: -size * 0.2)

            // Bordo luminoso
            StarShape(points: 5, innerRatio: 0.4)
                .stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.8), color.highlightColor.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
                .frame(width: size * 0.8, height: size * 0.8)
        }
        .frame(width: size, height: size)
    }
}

struct StarShape: Shape {
    let points: Int
    let innerRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * innerRatio

        var path = Path()
        let angleIncrement = .pi * 2 / CGFloat(points * 2)

        for i in 0..<(points * 2) {
            let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
            let angle = CGFloat(i) * angleIncrement - .pi / 2
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )

            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Diamond Shape View

struct DiamondShapeView: View {
    let color: BallColor
    let size: CGFloat

    var body: some View {
        ZStack {
            // Ombra
            DiamondShape()
                .fill(color.shadowColor)
                .frame(width: size * 0.8, height: size * 0.9)
                .blur(radius: 4)
                .offset(y: 3)

            // Glow colorato
            DiamondShape()
                .fill(color.color.opacity(0.5))
                .frame(width: size * 0.85, height: size * 0.95)
                .blur(radius: 8)

            // Corpo diamante - gradiente prismatico
            DiamondShape()
                .fill(
                    LinearGradient(
                        colors: [
                            color.highlightColor.opacity(0.95),
                            color.color,
                            color.highlightColor.opacity(0.8),
                            color.shadowColor
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size * 0.75, height: size * 0.85)

            // Faccia sfaccettata - sinistra superiore
            Path { path in
                let w = size * 0.75
                let h = size * 0.85
                let offsetX = (size - w) / 2
                let offsetY = (size - h) / 2
                path.move(to: CGPoint(x: offsetX + w / 2, y: offsetY))
                path.addLine(to: CGPoint(x: offsetX, y: offsetY + h / 2))
                path.addLine(to: CGPoint(x: offsetX + w / 2, y: offsetY + h / 2))
                path.closeSubpath()
            }
            .fill(color.highlightColor.opacity(0.5))

            // Faccia sfaccettata - destra superiore
            Path { path in
                let w = size * 0.75
                let h = size * 0.85
                let offsetX = (size - w) / 2
                let offsetY = (size - h) / 2
                path.move(to: CGPoint(x: offsetX + w / 2, y: offsetY))
                path.addLine(to: CGPoint(x: offsetX + w, y: offsetY + h / 2))
                path.addLine(to: CGPoint(x: offsetX + w / 2, y: offsetY + h / 2))
                path.closeSubpath()
            }
            .fill(color.color.opacity(0.4))

            // Riflesso prismatico
            DiamondShape()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.9),
                            Color.clear,
                            Color.white.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2
                )
                .frame(width: size * 0.75, height: size * 0.85)

            // Punto luce superiore
            Circle()
                .fill(Color.white.opacity(0.95))
                .frame(width: size * 0.12, height: size * 0.12)
                .offset(x: -size * 0.1, y: -size * 0.25)
                .blur(radius: 1)

            // Riflesso secondario
            Ellipse()
                .fill(Color.white.opacity(0.5))
                .frame(width: size * 0.2, height: size * 0.1)
                .offset(x: size * 0.1, y: size * 0.1)
        }
        .frame(width: size, height: size)
    }
}

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.backgroundDark.ignoresSafeArea()

        VStack(spacing: 30) {
            Text("FASE 3: Forme")
                .font(.title.bold())
                .foregroundColor(.white)

            HStack(spacing: 20) {
                VStack {
                    CubeShapeView(color: .red, size: 50)
                    Text("Cubo").font(.caption).foregroundColor(.white)
                }

                VStack {
                    PyramidShapeView(color: .blue, size: 50)
                    Text("Piramide").font(.caption).foregroundColor(.white)
                }

                VStack {
                    StarShapeView(color: .yellow, size: 50)
                    Text("Stella").font(.caption).foregroundColor(.white)
                }

                VStack {
                    DiamondShapeView(color: .purple, size: 50)
                    Text("Diamante").font(.caption).foregroundColor(.white)
                }
            }

            // Tutti i colori con cubo
            HStack(spacing: 15) {
                ForEach(BallColor.allCases.prefix(6), id: \.self) { ballColor in
                    CubeShapeView(color: ballColor, size: 40)
                }
            }
        }
    }
}
