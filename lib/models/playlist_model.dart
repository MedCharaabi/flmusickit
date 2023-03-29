import 'package:flmusickit/entity/playlist.dart';

class PlaylistModel extends Playlist {
  PlaylistModel({required super.id, required super.name});

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(id: json['id'], name: json['name']);
  }
}
