import 'package:flmusickit/entity/song.dart';

class SongModel extends Song {
  SongModel(super.id, super.title, super.artist, super.album, super.artwork,
      super.duration);

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      json['id'],
      json['title'],
      json['artist'],
      json['album'],
      json['albumArt'],
      Duration(milliseconds: (json['duration'] as double).toInt()),
    );
  }
}
