import MediaPlayer
import Observation
import UIKit

/// Snapshot of a track for the toast, so its content stays fixed while on screen.
struct TrackInfo: Equatable {
    let title: String
    let artist: String?
    let artwork: UIImage?
}

/// Wraps the system music player: now-playing metadata, play/pause state and transport control.
/// Only Apple Music is controllable this way; iOS offers no general remote for other audio apps.
@Observable
final class MusicModel {
    private(set) var title: String?
    private(set) var artist: String?
    private(set) var artwork: UIImage?
    private(set) var isPlaying = false
    /// Non-nil while the now-playing toast should be on screen.
    private(set) var toast: TrackInfo?

    static let toastDuration: Duration = .seconds(3)

    @ObservationIgnored private let player = MPMusicPlayerController.systemMusicPlayer
    @ObservationIgnored private var observers: [NSObjectProtocol] = []
    @ObservationIgnored private var nowPlayingID: UInt64?
    @ObservationIgnored private var dismissTask: Task<Void, Never>?
    #if DEBUG
    /// Fake track for the Simulator, which has no music library. Survives refreshes.
    @ObservationIgnored private var sampleTrack: TrackInfo?
    #endif

    init() {
        // Playback control works without this, but nowPlayingItem is nil until the library is authorized.
        MPMediaLibrary.requestAuthorization { [weak self] _ in
            DispatchQueue.main.async { self?.refresh() }
        }

        player.beginGeneratingPlaybackNotifications()
        let center = NotificationCenter.default
        observers = [
            center.addObserver(forName: .MPMusicPlayerControllerPlaybackStateDidChange,
                               object: player, queue: .main) { [weak self] _ in self?.refresh() },
            center.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
                               object: player, queue: .main) { [weak self] _ in self?.trackChanged() },
        ]
        refresh()

        #if DEBUG
        if CommandLine.arguments.contains("--sample-toast") {
            Task {
                try? await Task.sleep(for: .seconds(2))
                showToast(TrackInfo(title: "Sample Track", artist: "Sample Artist", artwork: nil))
            }
        }
        if CommandLine.arguments.contains("--sample-track") {
            sampleTrack = TrackInfo(title: "Radar Love", artist: "Golden Earring", artwork: nil)
            refresh()
        }
        #endif
    }

    deinit {
        player.endGeneratingPlaybackNotifications()
        observers.forEach(NotificationCenter.default.removeObserver)
    }

    /// Re-reads player state. Called on notifications and when the app returns to the foreground,
    /// since lock-screen and headphone controls change state while we're not listening.
    func refresh() {
        #if DEBUG
        if let sampleTrack {
            title = sampleTrack.title
            artist = sampleTrack.artist
            isPlaying = true
            return
        }
        #endif
        isPlaying = player.playbackState == .playing
        let item = player.nowPlayingItem
        title = item?.title
        artist = item?.artist
        artwork = item?.artwork?.image(at: CGSize(width: 120, height: 120))
        nowPlayingID = item?.persistentID
    }

    private func trackChanged() {
        let previous = nowPlayingID
        refresh()
        guard ToastGate.shouldShow(previous: previous, current: nowPlayingID), let title else { return }
        showToast(TrackInfo(title: title, artist: artist, artwork: artwork))
    }

    private func showToast(_ info: TrackInfo) {
        dismissTask?.cancel()
        toast = info
        dismissTask = Task {
            try? await Task.sleep(for: Self.toastDuration)
            guard !Task.isCancelled else { return }
            toast = nil
        }
    }

    func togglePlayPause() {
        isPlaying ? player.pause() : player.play()
    }

    func next() {
        player.skipToNextItem()
    }

    func previous() {
        player.skipToPreviousItem()
    }
}
