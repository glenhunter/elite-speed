import SwiftUI

/// Racing stripes as fractions of the zone, so they scale like paint on a car whatever the screen.
/// Bands run along the phone's long axis: vertical in portrait, horizontal in landscape.
nonisolated struct Stripes: Equatable {
    struct Band: Equatable {
        /// Fraction of the zone's cross-axis where the band starts.
        let start: Double
        /// Fraction of the zone's cross-axis the band covers.
        let width: Double
        let color: Color
    }

    let bands: [Band]

    /// A centred band with a thin pinstripe either side, all as fractions of the cross-axis.
    static func centred(width: Double, color: Color, pinstripe: Double, pinstripeColor: Color) -> Stripes {
        let start = (1 - width) / 2
        return Stripes(bands: [
            Band(start: start - pinstripe, width: pinstripe, color: pinstripeColor),
            Band(start: start, width: width, color: color),
            Band(start: start + width, width: pinstripe, color: pinstripeColor),
        ])
    }

    /// Frames for each band in a zone of `size`, with bands running along `axis`.
    func frames(in size: CGSize, axis: Axis) -> [CGRect] {
        bands.map { band in
            switch axis {
            case .vertical:
                CGRect(x: size.width * band.start, y: 0, width: size.width * band.width, height: size.height)
            case .horizontal:
                CGRect(x: 0, y: size.height * band.start, width: size.width, height: size.height * band.width)
            }
        }
    }
}

/// Draws a palette's stripes behind a zone's content.
struct StripesView: View {
    let stripes: Stripes
    let axis: Axis

    var body: some View {
        GeometryReader { geometry in
            ForEach(Array(stripes.frames(in: geometry.size, axis: axis).enumerated()), id: \.offset) { index, frame in
                Rectangle()
                    .fill(stripes.bands[index].color)
                    .frame(width: frame.width, height: frame.height)
                    .position(x: frame.midX, y: frame.midY)
            }
        }
        .accessibilityHidden(true)
    }
}
