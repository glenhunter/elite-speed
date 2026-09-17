import MediaPlayer
import Observation
import UIKit

/// Wraps the system music player: now-playing metadata, play/pause state and transport control.
/// Only Apple Music is controllable this way; iOS offers no general remote for other audio apps.
@Observable
final class MusicModel {
    private(set) var title: String?
    private(set) var artist: String?
    private(set) var artwork: UIImage?
    private(set) var isPlaying = false

    @ObservationIgnored private let player = MPMusicPlayerController.systemMusicPlayer
    @ObservationIgnored private var observers: [NSObjectProtocol] = []

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
                               object: player, queue: .main) { [weak self] _ in self?.refresh() },
        ]
        refresh()
    }

    deinit {
        player.endGeneratingPlaybackNotifications()
        observers.forEach(NotificationCenter.default.removeObserver)
    }

    /// Re-reads player state. Called on notifications and when the app returns to the foreground,
    /// since lock-screen and headphone controls change state while we're not listening.
    func refresh() {
        isPlaying = player.playbackState == .playing
        let item = player.nowPlayingItem
        title = item?.title
        artist = item?.artist
        artwork = item?.artwork?.image(at: CGSize(width: 120, height: 120))
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
