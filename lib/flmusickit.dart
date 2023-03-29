import 'package:flmusickit/core/enums/authorization_status.dart';
import 'package:flmusickit/core/enums/player_state.dart';
import 'package:flmusickit/entity/playlist.dart';
import 'package:flmusickit/entity/song.dart';

import 'flmusickit_platform_interface.dart';

class Flmusickit implements FlmusickitPlatform {
  @override
  Future<AuthorizationStatus> connectToAppleMusic() async {
    return await await FlmusickitPlatform.instance.connectToAppleMusic();
  }

  @override
  Future<AuthorizationStatus> getStatus() async {
    return await FlmusickitPlatform.instance.getStatus();
  }

  @override
  Future<List<Playlist>?> getPlaylists() async {
    return await FlmusickitPlatform.instance.getPlaylists();
  }

  @override
  Future<void> playPlaylist(String playlistId) async {
    return await FlmusickitPlatform.instance.playPlaylist(playlistId);
  }

  @override
  Future<void> pause() async {
    return await FlmusickitPlatform.instance.pause();
  }

  @override
  Future<void> play() async {
    return await FlmusickitPlatform.instance.play();
  }

  @override
  Future<void> skipNext() async {
    return await FlmusickitPlatform.instance.skipNext();
  }

  @override
  Future<void> skipPrevious() async {
    return await FlmusickitPlatform.instance.skipPrevious();
  }

  @override
  Future<void> stop() async {
    return await FlmusickitPlatform.instance.stop();
  }

  @override
  Stream<Song?>? currentSongStream() {
    return FlmusickitPlatform.instance.currentSongStream();
  }

  @override
  Future<Song?> currentSong() async {
    final currentSong = await FlmusickitPlatform.instance.currentSong();
    return currentSong;
  }

  @override
  Future<PlayerState> playerState() async {
    return await FlmusickitPlatform.instance.playerState();
  }

  @override
  Stream<PlayerState?>? playerStateStream() {
    return FlmusickitPlatform.instance.playerStateStream();
  }
}
