import ImageProcessor
import SwiftUI

struct GallerySpatialEffectOverlay: View {
    enum Style { case radial, linear, frame }

    let mask: ImageSpatialEffectMask
    let rotationDegrees: Int
    var style: Style = .radial
    var effectRotation: Double = 0
    let onCenterChange: (Double, Double) -> Void
    let onCenterChangeEnded: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let displayCenter = GallerySpatialEffectGeometry.displayPoint(
                centerX: mask.centerX,
                centerY: mask.centerY,
                rotationDegrees: rotationDegrees
            )
            let diameter = max(proxy.size.width, proxy.size.height) * mask.radius * 2

            ZStack {
                focusGuide(diameter: diameter, proxy: proxy, center: displayCenter)

                ZStack {
                    Circle().fill(.black.opacity(0.55)).frame(width: 28, height: 28)
                    Circle().stroke(.white, lineWidth: 2).frame(width: 18, height: 18)
                    Circle().fill(.white).frame(width: 4, height: 4)
                }
                .position(
                    x: displayCenter.x * proxy.size.width,
                    y: displayCenter.y * proxy.size.height
                )
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let point = GallerySpatialEffectGeometry.imagePoint(
                            displayPoint: CGPoint(
                                x: value.location.x / max(proxy.size.width, 1),
                                y: value.location.y / max(proxy.size.height, 1)
                            ),
                            rotationDegrees: rotationDegrees
                        )
                        onCenterChange(Double(point.x), Double(point.y))
                    }
                    .onEnded { _ in onCenterChangeEnded() }
            )
            .accessibilityLabel("Effect spot")
            .accessibilityHint("Drag to position the effect on the photo")
        }
    }

    @ViewBuilder
    private func focusGuide(
        diameter: CGFloat,
        proxy: GeometryProxy,
        center: CGPoint
    ) -> some View {
        switch style {
        case .radial:
            Circle()
                .strokeBorder(.white.opacity(0.82), style: guideStroke)
                .frame(width: diameter, height: diameter)
                .position(x: center.x * proxy.size.width, y: center.y * proxy.size.height)
        case .linear:
            Rectangle()
                .strokeBorder(.white.opacity(0.82), style: guideStroke)
                .frame(width: proxy.size.width * 1.5, height: diameter * 0.55)
                .rotationEffect(
                    .degrees(
                        GallerySpatialEffectGeometry.linearGuideRotationDegrees(
                            effectRotation: effectRotation,
                            imageRotationDegrees: rotationDegrees
                        )
                    )
                )
                .position(x: center.x * proxy.size.width, y: center.y * proxy.size.height)
        case .frame:
            RoundedRectangle(cornerRadius: min(proxy.size.width, proxy.size.height) * mask.radius * 0.09)
                .strokeBorder(.white.opacity(0.82), style: guideStroke)
                .frame(
                    width: proxy.size.width * mask.radius * 1.55,
                    height: proxy.size.height * mask.radius * 1.55
                )
                .position(x: center.x * proxy.size.width, y: center.y * proxy.size.height)
        }
    }

    private var guideStroke: StrokeStyle {
        StrokeStyle(lineWidth: 1.5, dash: [6, 5])
    }
}

enum GallerySpatialEffectGeometry {
    static func linearGuideRotationDegrees(
        effectRotation: Double,
        imageRotationDegrees: Int
    ) -> Double {
        Double(ImageEditRotation.normalized(imageRotationDegrees)) - effectRotation * 180
    }

    static func imagePoint(
        displayPoint point: CGPoint,
        rotationDegrees: Int
    ) -> CGPoint {
        let point = clamped(point)
        switch ImageEditRotation.normalized(rotationDegrees) {
        case 90: return CGPoint(x: point.y, y: 1 - point.x)
        case 180: return CGPoint(x: 1 - point.x, y: 1 - point.y)
        case 270: return CGPoint(x: 1 - point.y, y: point.x)
        default: return point
        }
    }

    static func displayPoint(
        centerX: Double,
        centerY: Double,
        rotationDegrees: Int
    ) -> CGPoint {
        let point = CGPoint(x: CGFloat(centerX), y: CGFloat(centerY))
        switch ImageEditRotation.normalized(rotationDegrees) {
        case 90: return clamped(CGPoint(x: 1 - point.y, y: point.x))
        case 180: return clamped(CGPoint(x: 1 - point.x, y: 1 - point.y))
        case 270: return clamped(CGPoint(x: point.y, y: 1 - point.x))
        default: return clamped(point)
        }
    }

    private static func clamped(_ point: CGPoint) -> CGPoint {
        CGPoint(x: min(max(point.x, 0), 1), y: min(max(point.y, 0), 1))
    }
}
