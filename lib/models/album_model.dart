import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:xml/xml.dart' as xml;

class Album extends Equatable {
  final int id;
  final String title;
  final String artist;
  final int artistId;
  final int songCount;
  final String art;
  final DateTime date;
  final String genre;
  final int year;
  final int mostPlayed;

  const Album({
    this.id,
    this.title,
    this.artist,
    this.artistId,
    this.songCount,
    this.art,
    this.date,
    this.genre,
    this.year,
    this.mostPlayed,
  });

  @override
  List<Object> get props => [id, title, artist];

  factory Album.fromServer(xml.XmlElement element) => (Album(
        id: int.parse(element.getAttribute('id')),
        title: element.getAttribute('name'),
        artist: element.getAttribute('artist'),
        artistId: int.parse(element.getAttribute('artistId')),
        songCount: int.parse(element.getAttribute('songCount')),
        art: element.getAttribute('coverArt'),
        date: DateTime.parse(element.getAttribute('created')),
        genre: element.getAttribute('genre'),
        year: element.getAttribute('year') != null
            ? int.parse(element.getAttribute('year'))
            : null,
      ));

  factory Album.fromSQL(Map<String, dynamic> json) => Album(
      id: json['id'],
      title: json['title'],
      artist: json['artist'],
      artistId: json['artistId'],
      songCount: json['songCount'],
      art: json['art'],
      date: DateTime.parse(json['date']),
      genre: json['genre'],
      year: json['year'],
      mostPlayed: json['mostPlayed']);

  Map<String, dynamic> toSQL() => {
        'id': id,
        'title': title,
        'artist': artist,
        'artistId': artistId,
        'songCount': songCount,
        'art': art,
        'date': date.toString(),
        'genre': genre,
        'year': year,
        'mostPlayed': mostPlayed,
      };
}
