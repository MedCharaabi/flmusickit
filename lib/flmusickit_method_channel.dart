import 'dart:developer';

import 'package:flmusickit/core/enums/authorization_status.dart';
import 'package:flmusickit/core/enums/player_state.dart';
import 'package:flmusickit/entity/playlist.dart';
import 'package:flmusickit/entity/song.dart';
import 'package:flmusickit/models/event_model.dart';
import 'package:flmusickit/models/playlist_model.dart';
import 'package:flmusickit/models/song_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'entity/event.dart';
import 'flmusickit_platform_interface.dart';

/// An implementation of [FlmusickitPlatform] that uses method channels.
class MethodChannelFlmusickit implements FlmusickitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flmusickit');

  @visibleForTesting
  final songEventChannel = const EventChannel('flmusickit/song');
  final playbackChannel = const EventChannel('flmusickit/playback');

  @override
  Future<AuthorizationStatus> connectToAppleMusic() async {
    final String? authenticationResult =
        await methodChannel.invokeMethod<String>('connectToAppleMusic');
    final status = AuthorizationStatus.values.firstWhere(
      (element) => describeEnum(element) == authenticationResult,
      orElse: () => AuthorizationStatus.notDetermined,
    );
    return status;
  }

  @override
  Future<AuthorizationStatus> getStatus() async {
    final strStatus = await methodChannel.invokeMethod<String>('status');
    log("strStatus: $strStatus");
    final status = AuthorizationStatus.values.firstWhere(
      (element) => describeEnum(element) == strStatus,
      orElse: () => AuthorizationStatus.restricted,
    );
    return status;
  }

  @override
  Future<List<Playlist>?> getPlaylists() async {
    final playlists = await methodChannel.invokeMethod('getPlaylists');

    if (playlists == null) return null;

    final List<Playlist> result = [];
    for (var playlist in playlists) {
      print("[flmusickit] playlist: ${playlist.runtimeType}");

      Map<String, dynamic> json = {};
      for (var entry in (playlist as Map<Object?, Object?>).entries) {
        json[entry.key.toString()] = entry.value;
      }

      result.add(PlaylistModel.fromJson(json));
    }

    return result;
  }

  @override
  Future<void> playPlaylist(String playlistId) async {
    final result = await methodChannel.invokeMethod(
        'playPlaylist', <String, dynamic>{"playlistId": playlistId});
    return result;
  }

  @override
  Future<void> pause() async {
    final result = await methodChannel.invokeMethod('pause');
    return result;
  }

  @override
  Future<void> play() async {
    final result = await methodChannel.invokeMethod('play');
    return result;
  }

  @override
  Future<void> stop() async {
    final result = await methodChannel.invokeMethod('stop');
    return result;
  }

  @override
  Future<void> skipNext() async {
    final result = await methodChannel.invokeMethod('next');
    return result;
  }

  @override
  Future<void> skipPrevious() async {
    final result = await methodChannel.invokeMethod('previous');
    return result;
  }

  Stream<Song?>? _currentSong;
  @override
  Stream<Song?>? currentSongStream() {
    _currentSong ??= songEventChannel.receiveBroadcastStream().map((event) {
      Map<String, dynamic> json = {};
      for (var entry in (event as Map<Object?, Object?>).entries) {
        json[entry.key.toString()] = entry.value;
      }

      final Event eventData = EventModel.fromJson(json);
      print(
          "[flmusickit] change: eventData is nowPlaying: ${eventData.type == EventType.nowPlaying}");

      if (eventData.type == EventType.nowPlaying) {
        Map<String, dynamic> dataJson = {};
        for (var entry in (eventData.data as Map<Object?, Object?>).entries) {
          dataJson[entry.key.toString()] = entry.value;
        }
        final Song song = SongModel.fromJson(dataJson);
        print("[flmusickit] song: ${song.title}");
        return song;
      }
    });

    return _currentSong;
  }

  @override
  Future<Song?> currentSong() async {
    final currentSong = await methodChannel.invokeMethod('currentSong');

    if (currentSong == null) return null;

    Map<String, dynamic> json = {};
    for (var entry in (currentSong as Map<Object?, Object?>).entries) {
      json[entry.key.toString()] = entry.value;
    }

    return SongModel.fromJson(json);
  }

  @override
  Future<PlayerState> playerState() async {
    final result = await methodChannel.invokeMethod('playerState');

    final state = PlayerState.values[result as int];
    print("[flmusickit] playerState: $state");

    return state;
  }

  Stream<PlayerState?>? _playerState;
  @override
  Stream<PlayerState?>? playerStateStream() {
    _playerState ??= playbackChannel.receiveBroadcastStream().map((event) {
      Map<String, dynamic> json = {};
      for (var entry in (event as Map<Object?, Object?>).entries) {
        json[entry.key.toString()] = entry.value;
      }

      final Event eventData = EventModel.fromJson(json);
      print(
          "[flmusickit change: event is PlayerState: ${eventData.type == EventType.playerState}");

      if (eventData.type == EventType.playerState) {
        final state = PlayerState.values[eventData.data as int];
        print("[flmusickit] new playerState: $state");
        return state;
      }
    });

    return _playerState;
  }
}
