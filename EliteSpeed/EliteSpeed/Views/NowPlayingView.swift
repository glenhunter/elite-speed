import SwiftUI

/// Title and artist of the current track, for the landscape column. Empty when nothing is known.
struct NowPlayingView: View {
    @Environment(MusicModel.self) private var music

    var body: some View {
        if let title = music.title {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.speedo(.semiBold, size: 16))
                    .lineLimit(2)
                if let artist = music.artist {
                    Text(artist)
                        .font(.speedo(size: 14))
                        .lineLimit(1)
                        .opacity(0.7)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Now playing")
            .accessibilityValue([title, music.artist].compactMap { $0 }.joined(separator: ", "))
        }
    }
}

#Preview {
    NowPlayingView()
        .environment(MusicModel())
}
