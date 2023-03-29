import 'dart:math';

import 'package:flmusickit/core/enums/authorization_status.dart';
import 'package:flmusickit/core/enums/player_state.dart';
import 'package:flmusickit/entity/playlist.dart';
import 'package:flmusickit/entity/song.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flmusickit_method_channel.dart';

abstract class FlmusickitPlatform extends PlatformInterface {
  /// Constructs a FlmusickitPlatform.
  FlmusickitPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlmusickitPlatform _instance = MethodChannelFlmusickit();

  /// The default instance of [FlmusickitPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlmusickit].
  static FlmusickitPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlmusickitPlatform] when
  /// they register themselves.
  static set instance(FlmusickitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<AuthorizationStatus> connectToAppleMusic();
  Future<AuthorizationStatus> getStatus();

  Future<List<Playlist>?> getPlaylists();
  Future<void> playPlaylist(String playlisId);
  Future<void> skipPrevious();
  Future<void> skipNext();
  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<PlayerState> playerState();
  Stream<Song?>? currentSongStream();
  Future<Song?> currentSong();
  Stream<PlayerState?>? playerStateStream();
}
