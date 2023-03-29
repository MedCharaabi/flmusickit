import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flmusickit/core/enums/authorization_status.dart';
import 'package:flmusickit/core/enums/player_state.dart';
import 'package:flmusickit/entity/playlist.dart';
import 'package:flmusickit/entity/song.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flmusickit/flmusickit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _flmusickitPlugin = Flmusickit();

  AuthorizationStatus _authStatus = AuthorizationStatus.notDetermined;

  Uint8List convertStringToUint8List(String str) {
    final Uint8List unit8List = base64Decode(str);

    return unit8List;
  }

  final ValueNotifier<PlayerState> _playerState =
      ValueNotifier(PlayerState.stopped);
  final ValueNotifier<Song?> _currentSong = ValueNotifier(null);

  bool _isLoading = true;

  _getCurrentPlayerState() async {
    final state = await _flmusickitPlugin.playerState();
    _playerState.value = state;
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _flmusickitPlugin.getStatus().then((value) {
      log(value.toString());

      setState(() {
        _authStatus = value;
      });
    });

    _getCurrentPlayerState();

    _flmusickitPlugin.playerStateStream()?.listen((state) {
      if (state != null) {
        _playerState.value = state;
      }
    });

    _flmusickitPlugin.currentSongStream()?.listen((song) {
      if (song != null) {
        _currentSong.value = song;
      }
    });
  }

  List<Playlist> _playlists = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: SizedBox.expand(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text("STATUS: ${_authStatus.name}"),
                      if (_authStatus != AuthorizationStatus.authorized)
                        ElevatedButton(
                          child: Text(
                              _authStatus != AuthorizationStatus.authorized
                                  ? "Connect to Apple Music"
                                  : "Connected to Apple Music"),
                          onPressed: () async {
                            final AuthorizationStatus authenticationResult =
                                await _flmusickitPlugin.connectToAppleMusic();

                            setState(() {
                              _authStatus = authenticationResult;
                            });
                          },
                        ),
                      if (_authStatus == AuthorizationStatus.authorized)
                        ElevatedButton(
                            onPressed: () async {
                              final playlists =
                                  await _flmusickitPlugin.getPlaylists();

                              log("playlists: $playlists");

                              setState(() {
                                _playlists = playlists ?? [];
                              });
                            },
                            child: const Text("Get Playlists")),
                      if (_authStatus == AuthorizationStatus.authorized)
                        ValueListenableBuilder<Song?>(
                            valueListenable: _currentSong,
                            builder: (context, currentSong, _) {
                              if (currentSong == null) {
                                return const Text("No song playing");
                              }

                              return Row(
                                children: [
                                  currentSong.artwork != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Image.memory(
                                            convertStringToUint8List(
                                                currentSong.artwork!),
                                            height: 100,
                                            width: 100,
                                          ),
                                        )
                                      : Container(
                                          height: 100,
                                          width: 100,
                                          decoration: const BoxDecoration(
                                            color: Colors.black,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                  Text("Current Song: ${currentSong.title}"),
                                ],
                              );
                            }),
                      if (_playlists.isNotEmpty)
                        Expanded(
                          child: ListView.builder(
                            itemCount: _playlists.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                  tileColor: Colors.amber,
                                  leading: const Icon(Icons.music_note),
                                  title: Text(_playlists[index].name),
                                  onTap: () async {
                                    await _flmusickitPlugin
                                        .playPlaylist(_playlists[index].name);
                                  });
                            },
                          ),
                        ),
                      if (_authStatus == AuthorizationStatus.authorized)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                  onPressed: () async {
                                    await _flmusickitPlugin.skipPrevious();
                                  },
                                  icon: const Icon(Icons.skip_previous)),
                              ValueListenableBuilder<PlayerState?>(
                                  valueListenable: _playerState,
                                  builder: (context, playerState, _) {
                                    return IconButton(
                                        onPressed: () async {
                                          if (playerState ==
                                              PlayerState.playing) {
                                            await _flmusickitPlugin.pause();
                                          } else {
                                            await _flmusickitPlugin.play();
                                          }
                                        },
                                        icon: Icon(
                                          playerState == PlayerState.playing
                                              ? Icons.pause
                                              : Icons.play_arrow,
                                        ));
                                  }),
                              IconButton(
                                  onPressed: () async {
                                    await _flmusickitPlugin.skipNext();
                                  },
                                  icon: const Icon(Icons.skip_next))
                            ],
                          ),
                        ),
                      if (_authStatus == AuthorizationStatus.authorized)
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ElevatedButton(
                                  onPressed: () async {
                                    final currentsong =
                                        await _flmusickitPlugin.currentSong();
                                    print(
                                        "[flmusickit] current Song: $currentsong");
                                  },
                                  child: const Text("Get Current Song")),
                              ElevatedButton(
                                  onPressed: () async {
                                    final PlayerState state =
                                        await _flmusickitPlugin.playerState();

                                    print("[flmusickit] state: $state");
                                  },
                                  child: Text("Get Current PlayerState"))
                            ],
                          ),
                        ),
                    ],
                  ),
          )),
    );
  }
}
