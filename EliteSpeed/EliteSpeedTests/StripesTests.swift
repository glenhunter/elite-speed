import SwiftUI
import Testing
@testable import EliteSpeed

struct StripesTests {
    // One band from 20% to 30% of the width.
    static let lotus = Stripes(bands: [Stripes.Band(start: 0.20, width: 0.10, color: .yellow)])

    @Test func verticalBandScalesToTheZoneWidth() {
        let frames = Self.lotus.frames(in: CGSize(width: 400, height: 800), axis: .vertical)
        #expect(frames == [CGRect(x: 80, y: 0, width: 40, height: 800)])
    }

    @Test func horizontalBandScalesToTheZoneHeight() {
        let frames = Self.lotus.frames(in: CGSize(width: 800, height: 400), axis: .horizontal)
        #expect(frames == [CGRect(x: 0, y: 80, width: 800, height: 40)])
    }

    @Test func centredBandHasPinstripesEitherSide() {
        let s = Stripes.centred(width: 0.20, color: .yellow, pinstripe: 0.02, pinstripeColor: .white)
        let frames = s.frames(in: CGSize(width: 100, height: 10), axis: .vertical)
        #expect(frames.map { ($0.minX * 1000).rounded() / 1000 } == [38, 40, 60])
        #expect(frames.map { ($0.width * 1000).rounded() / 1000 } == [2, 20, 2])
    }

    @Test func bandsKeepTheirOrder() {
        let tricolour = Stripes(bands: [
            Stripes.Band(start: 0.60, width: 0.04, color: .blue),
            Stripes.Band(start: 0.65, width: 0.04, color: .purple),
            Stripes.Band(start: 0.70, width: 0.04, color: .red),
        ])
        let frames = tricolour.frames(in: CGSize(width: 100, height: 10), axis: .vertical)
        #expect(frames.map(\.minX) == [60, 65, 70])
    }
}
