// To parse this JSON data, do
//
//     final songs = songsFromJson(jsonString);

import 'dart:convert';

Songs songsFromJson(String str) => Songs.fromJson(json.decode(str));

String songsToJson(Songs data) => json.encode(data.toJson());

class Songs {
  String title;
  String artist;
  String audioUrl;

  Songs({
    required this.title,
    required this.artist,
    required this.audioUrl,
  });

  factory Songs.fromJson(Map<String, dynamic> json) => Songs(
    title: json["title"],
    artist: json["artist"],
    audioUrl: json["audioUrl"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "artist": artist,
    "audioUrl": audioUrl,
  };
}