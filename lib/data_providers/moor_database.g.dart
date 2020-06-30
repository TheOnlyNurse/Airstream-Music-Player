// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_database.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class Album extends DataClass implements Insertable<Album> {
  final int id;
  final String title;
  final String artist;
  final int artistId;
  final int songCount;
  final String art;
  final DateTime created;
  final String genre;
  final int year;
  Album(
      {@required this.id,
      @required this.title,
      @required this.artist,
      @required this.artistId,
      @required this.songCount,
      @required this.art,
      @required this.created,
      this.genre,
      this.year});
  factory Album.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    return Album(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      title:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}title']),
      artist:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}artist']),
      artistId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}artist_id']),
      songCount:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}song_count']),
      art: stringType.mapFromDatabaseResponse(data['${effectivePrefix}art']),
      created: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created']),
      genre:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}genre']),
      year: intType.mapFromDatabaseResponse(data['${effectivePrefix}year']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || artistId != null) {
      map['artist_id'] = Variable<int>(artistId);
    }
    if (!nullToAbsent || songCount != null) {
      map['song_count'] = Variable<int>(songCount);
    }
    if (!nullToAbsent || art != null) {
      map['art'] = Variable<String>(art);
    }
    if (!nullToAbsent || created != null) {
      map['created'] = Variable<DateTime>(created);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    return map;
  }

  AlbumsCompanion toCompanion(bool nullToAbsent) {
    return AlbumsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      artist:
          artist == null && nullToAbsent ? const Value.absent() : Value(artist),
      artistId: artistId == null && nullToAbsent
          ? const Value.absent()
          : Value(artistId),
      songCount: songCount == null && nullToAbsent
          ? const Value.absent()
          : Value(songCount),
      art: art == null && nullToAbsent ? const Value.absent() : Value(art),
      created: created == null && nullToAbsent
          ? const Value.absent()
          : Value(created),
      genre:
          genre == null && nullToAbsent ? const Value.absent() : Value(genre),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
    );
  }

  factory Album.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Album(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String>(json['artist']),
      artistId: serializer.fromJson<int>(json['artistId']),
      songCount: serializer.fromJson<int>(json['songCount']),
      art: serializer.fromJson<String>(json['art']),
      created: serializer.fromJson<DateTime>(json['created']),
      genre: serializer.fromJson<String>(json['genre']),
      year: serializer.fromJson<int>(json['year']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String>(artist),
      'artistId': serializer.toJson<int>(artistId),
      'songCount': serializer.toJson<int>(songCount),
      'art': serializer.toJson<String>(art),
      'created': serializer.toJson<DateTime>(created),
      'genre': serializer.toJson<String>(genre),
      'year': serializer.toJson<int>(year),
    };
  }

  Album copyWith(
          {int id,
          String title,
          String artist,
          int artistId,
          int songCount,
          String art,
          DateTime created,
          String genre,
          int year}) =>
      Album(
        id: id ?? this.id,
        title: title ?? this.title,
        artist: artist ?? this.artist,
        artistId: artistId ?? this.artistId,
        songCount: songCount ?? this.songCount,
        art: art ?? this.art,
        created: created ?? this.created,
        genre: genre ?? this.genre,
        year: year ?? this.year,
      );
  @override
  String toString() {
    return (StringBuffer('Album(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('artistId: $artistId, ')
          ..write('songCount: $songCount, ')
          ..write('art: $art, ')
          ..write('created: $created, ')
          ..write('genre: $genre, ')
          ..write('year: $year')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          title.hashCode,
          $mrjc(
              artist.hashCode,
              $mrjc(
                  artistId.hashCode,
                  $mrjc(
                      songCount.hashCode,
                      $mrjc(
                          art.hashCode,
                          $mrjc(created.hashCode,
                              $mrjc(genre.hashCode, year.hashCode)))))))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Album &&
          other.id == this.id &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.artistId == this.artistId &&
          other.songCount == this.songCount &&
          other.art == this.art &&
          other.created == this.created &&
          other.genre == this.genre &&
          other.year == this.year);
}

class AlbumsCompanion extends UpdateCompanion<Album> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> artist;
  final Value<int> artistId;
  final Value<int> songCount;
  final Value<String> art;
  final Value<DateTime> created;
  final Value<String> genre;
  final Value<int> year;
  const AlbumsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.artistId = const Value.absent(),
    this.songCount = const Value.absent(),
    this.art = const Value.absent(),
    this.created = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
  });
  AlbumsCompanion.insert({
    this.id = const Value.absent(),
    @required String title,
    @required String artist,
    @required int artistId,
    @required int songCount,
    @required String art,
    @required DateTime created,
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
  })  : title = Value(title),
        artist = Value(artist),
        artistId = Value(artistId),
        songCount = Value(songCount),
        art = Value(art),
        created = Value(created);
  static Insertable<Album> custom({
    Expression<int> id,
    Expression<String> title,
    Expression<String> artist,
    Expression<int> artistId,
    Expression<int> songCount,
    Expression<String> art,
    Expression<DateTime> created,
    Expression<String> genre,
    Expression<int> year,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (artistId != null) 'artist_id': artistId,
      if (songCount != null) 'song_count': songCount,
      if (art != null) 'art': art,
      if (created != null) 'created': created,
      if (genre != null) 'genre': genre,
      if (year != null) 'year': year,
    });
  }

  AlbumsCompanion copyWith(
      {Value<int> id,
      Value<String> title,
      Value<String> artist,
      Value<int> artistId,
      Value<int> songCount,
      Value<String> art,
      Value<DateTime> created,
      Value<String> genre,
      Value<int> year}) {
    return AlbumsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistId: artistId ?? this.artistId,
      songCount: songCount ?? this.songCount,
      art: art ?? this.art,
      created: created ?? this.created,
      genre: genre ?? this.genre,
      year: year ?? this.year,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (artistId.present) {
      map['artist_id'] = Variable<int>(artistId.value);
    }
    if (songCount.present) {
      map['song_count'] = Variable<int>(songCount.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlbumsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('artistId: $artistId, ')
          ..write('songCount: $songCount, ')
          ..write('art: $art, ')
          ..write('created: $created, ')
          ..write('genre: $genre, ')
          ..write('year: $year')
          ..write(')'))
        .toString();
  }
}

class $AlbumsTable extends Albums with TableInfo<$AlbumsTable, Album> {
  final GeneratedDatabase _db;
  final String _alias;
  $AlbumsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn(
      'id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _titleMeta = const VerificationMeta('title');
  GeneratedTextColumn _title;
  @override
  GeneratedTextColumn get title => _title ??= _constructTitle();
  GeneratedTextColumn _constructTitle() {
    return GeneratedTextColumn(
      'title',
      $tableName,
      false,
    );
  }

  final VerificationMeta _artistMeta = const VerificationMeta('artist');
  GeneratedTextColumn _artist;
  @override
  GeneratedTextColumn get artist => _artist ??= _constructArtist();
  GeneratedTextColumn _constructArtist() {
    return GeneratedTextColumn(
      'artist',
      $tableName,
      false,
    );
  }

  final VerificationMeta _artistIdMeta = const VerificationMeta('artistId');
  GeneratedIntColumn _artistId;
  @override
  GeneratedIntColumn get artistId => _artistId ??= _constructArtistId();
  GeneratedIntColumn _constructArtistId() {
    return GeneratedIntColumn(
      'artist_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _songCountMeta = const VerificationMeta('songCount');
  GeneratedIntColumn _songCount;
  @override
  GeneratedIntColumn get songCount => _songCount ??= _constructSongCount();
  GeneratedIntColumn _constructSongCount() {
    return GeneratedIntColumn(
      'song_count',
      $tableName,
      false,
    );
  }

  final VerificationMeta _artMeta = const VerificationMeta('art');
  GeneratedTextColumn _art;
  @override
  GeneratedTextColumn get art => _art ??= _constructArt();
  GeneratedTextColumn _constructArt() {
    return GeneratedTextColumn(
      'art',
      $tableName,
      false,
    );
  }

  final VerificationMeta _createdMeta = const VerificationMeta('created');
  GeneratedDateTimeColumn _created;
  @override
  GeneratedDateTimeColumn get created => _created ??= _constructCreated();
  GeneratedDateTimeColumn _constructCreated() {
    return GeneratedDateTimeColumn(
      'created',
      $tableName,
      false,
    );
  }

  final VerificationMeta _genreMeta = const VerificationMeta('genre');
  GeneratedTextColumn _genre;
  @override
  GeneratedTextColumn get genre => _genre ??= _constructGenre();
  GeneratedTextColumn _constructGenre() {
    return GeneratedTextColumn(
      'genre',
      $tableName,
      true,
    );
  }

  final VerificationMeta _yearMeta = const VerificationMeta('year');
  GeneratedIntColumn _year;
  @override
  GeneratedIntColumn get year => _year ??= _constructYear();
  GeneratedIntColumn _constructYear() {
    return GeneratedIntColumn(
      'year',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [id, title, artist, artistId, songCount, art, created, genre, year];
  @override
  $AlbumsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'albums';
  @override
  final String actualTableName = 'albums';
  @override
  VerificationContext validateIntegrity(Insertable<Album> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title'], _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(_artistMeta,
          artist.isAcceptableOrUnknown(data['artist'], _artistMeta));
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('artist_id')) {
      context.handle(_artistIdMeta,
          artistId.isAcceptableOrUnknown(data['artist_id'], _artistIdMeta));
    } else if (isInserting) {
      context.missing(_artistIdMeta);
    }
    if (data.containsKey('song_count')) {
      context.handle(_songCountMeta,
          songCount.isAcceptableOrUnknown(data['song_count'], _songCountMeta));
    } else if (isInserting) {
      context.missing(_songCountMeta);
    }
    if (data.containsKey('art')) {
      context.handle(
          _artMeta, art.isAcceptableOrUnknown(data['art'], _artMeta));
    } else if (isInserting) {
      context.missing(_artMeta);
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created'], _createdMeta));
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    if (data.containsKey('genre')) {
      context.handle(
          _genreMeta, genre.isAcceptableOrUnknown(data['genre'], _genreMeta));
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year'], _yearMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Album map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Album.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $AlbumsTable createAlias(String alias) {
    return $AlbumsTable(_db, alias);
  }
}

class Artist extends DataClass implements Insertable<Artist> {
  final int id;
  final String name;
  final int albumCount;
  final String art;
  Artist(
      {@required this.id,
      @required this.name,
      @required this.albumCount,
      @required this.art});
  factory Artist.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return Artist(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      albumCount: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}album_count']),
      art: stringType.mapFromDatabaseResponse(data['${effectivePrefix}art']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || albumCount != null) {
      map['album_count'] = Variable<int>(albumCount);
    }
    if (!nullToAbsent || art != null) {
      map['art'] = Variable<String>(art);
    }
    return map;
  }

  ArtistsCompanion toCompanion(bool nullToAbsent) {
    return ArtistsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      albumCount: albumCount == null && nullToAbsent
          ? const Value.absent()
          : Value(albumCount),
      art: art == null && nullToAbsent ? const Value.absent() : Value(art),
    );
  }

  factory Artist.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Artist(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      albumCount: serializer.fromJson<int>(json['albumCount']),
      art: serializer.fromJson<String>(json['art']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'albumCount': serializer.toJson<int>(albumCount),
      'art': serializer.toJson<String>(art),
    };
  }

  Artist copyWith({int id, String name, int albumCount, String art}) => Artist(
        id: id ?? this.id,
        name: name ?? this.name,
        albumCount: albumCount ?? this.albumCount,
        art: art ?? this.art,
      );
  @override
  String toString() {
    return (StringBuffer('Artist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('albumCount: $albumCount, ')
          ..write('art: $art')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(id.hashCode,
      $mrjc(name.hashCode, $mrjc(albumCount.hashCode, art.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Artist &&
          other.id == this.id &&
          other.name == this.name &&
          other.albumCount == this.albumCount &&
          other.art == this.art);
}

class ArtistsCompanion extends UpdateCompanion<Artist> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> albumCount;
  final Value<String> art;
  const ArtistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.art = const Value.absent(),
  });
  ArtistsCompanion.insert({
    this.id = const Value.absent(),
    @required String name,
    @required int albumCount,
    @required String art,
  })  : name = Value(name),
        albumCount = Value(albumCount),
        art = Value(art);
  static Insertable<Artist> custom({
    Expression<int> id,
    Expression<String> name,
    Expression<int> albumCount,
    Expression<String> art,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (albumCount != null) 'album_count': albumCount,
      if (art != null) 'art': art,
    });
  }

  ArtistsCompanion copyWith(
      {Value<int> id,
      Value<String> name,
      Value<int> albumCount,
      Value<String> art}) {
    return ArtistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      albumCount: albumCount ?? this.albumCount,
      art: art ?? this.art,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (albumCount.present) {
      map['album_count'] = Variable<int>(albumCount.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('albumCount: $albumCount, ')
          ..write('art: $art')
          ..write(')'))
        .toString();
  }
}

class $ArtistsTable extends Artists with TableInfo<$ArtistsTable, Artist> {
  final GeneratedDatabase _db;
  final String _alias;
  $ArtistsTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn(
      'id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _nameMeta = const VerificationMeta('name');
  GeneratedTextColumn _name;
  @override
  GeneratedTextColumn get name => _name ??= _constructName();
  GeneratedTextColumn _constructName() {
    return GeneratedTextColumn(
      'name',
      $tableName,
      false,
    );
  }

  final VerificationMeta _albumCountMeta = const VerificationMeta('albumCount');
  GeneratedIntColumn _albumCount;
  @override
  GeneratedIntColumn get albumCount => _albumCount ??= _constructAlbumCount();
  GeneratedIntColumn _constructAlbumCount() {
    return GeneratedIntColumn(
      'album_count',
      $tableName,
      false,
    );
  }

  final VerificationMeta _artMeta = const VerificationMeta('art');
  GeneratedTextColumn _art;
  @override
  GeneratedTextColumn get art => _art ??= _constructArt();
  GeneratedTextColumn _constructArt() {
    return GeneratedTextColumn(
      'art',
      $tableName,
      false,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [id, name, albumCount, art];
  @override
  $ArtistsTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'artists';
  @override
  final String actualTableName = 'artists';
  @override
  VerificationContext validateIntegrity(Insertable<Artist> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name'], _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('album_count')) {
      context.handle(
          _albumCountMeta,
          albumCount.isAcceptableOrUnknown(
              data['album_count'], _albumCountMeta));
    } else if (isInserting) {
      context.missing(_albumCountMeta);
    }
    if (data.containsKey('art')) {
      context.handle(
          _artMeta, art.isAcceptableOrUnknown(data['art'], _artMeta));
    } else if (isInserting) {
      context.missing(_artMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Artist map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Artist.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $ArtistsTable createAlias(String alias) {
    return $ArtistsTable(_db, alias);
  }
}

class Song extends DataClass implements Insertable<Song> {
  final int id;
  final String title;
  final String album;
  final String artist;
  final String art;
  final int albumId;
  final bool isStarred;

  Song(
      {@required this.id,
      @required this.title,
      @required this.album,
      @required this.artist,
      @required this.art,
      @required this.albumId,
      this.isStarred});

  factory Song.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final boolType = db.typeSystem.forDartType<bool>();
    return Song(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      title:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}title']),
      album:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}album']),
      artist:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}artist']),
      art: stringType.mapFromDatabaseResponse(data['${effectivePrefix}art']),
      albumId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}album_id']),
      isStarred: boolType
          .mapFromDatabaseResponse(data['${effectivePrefix}is_starred']),
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || art != null) {
      map['art'] = Variable<String>(art);
    }
    if (!nullToAbsent || albumId != null) {
      map['album_id'] = Variable<int>(albumId);
    }
    if (!nullToAbsent || isStarred != null) {
      map['is_starred'] = Variable<bool>(isStarred);
    }
    return map;
  }

  SongsCompanion toCompanion(bool nullToAbsent) {
    return SongsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      album:
          album == null && nullToAbsent ? const Value.absent() : Value(album),
      artist:
          artist == null && nullToAbsent ? const Value.absent() : Value(artist),
      art: art == null && nullToAbsent ? const Value.absent() : Value(art),
      albumId: albumId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumId),
      isStarred: isStarred == null && nullToAbsent
          ? const Value.absent()
          : Value(isStarred),
    );
  }

  factory Song.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return Song(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      album: serializer.fromJson<String>(json['album']),
      artist: serializer.fromJson<String>(json['artist']),
      art: serializer.fromJson<String>(json['art']),
      albumId: serializer.fromJson<int>(json['albumId']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'album': serializer.toJson<String>(album),
      'artist': serializer.toJson<String>(artist),
      'art': serializer.toJson<String>(art),
      'albumId': serializer.toJson<int>(albumId),
      'isStarred': serializer.toJson<bool>(isStarred),
    };
  }

  Song copyWith(
          {int id,
          String title,
          String album,
          String artist,
          String art,
          int albumId,
          bool isStarred}) =>
      Song(
        id: id ?? this.id,
        title: title ?? this.title,
        album: album ?? this.album,
        artist: artist ?? this.artist,
        art: art ?? this.art,
        albumId: albumId ?? this.albumId,
        isStarred: isStarred ?? this.isStarred,
      );

  @override
  String toString() {
    return (StringBuffer('Song(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('album: $album, ')
          ..write('artist: $artist, ')
          ..write('art: $art, ')
          ..write('albumId: $albumId, ')
          ..write('isStarred: $isStarred')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(
          title.hashCode,
          $mrjc(
              album.hashCode,
              $mrjc(
                  artist.hashCode,
                  $mrjc(art.hashCode,
                      $mrjc(albumId.hashCode, isStarred.hashCode)))))));

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Song &&
          other.id == this.id &&
          other.title == this.title &&
          other.album == this.album &&
          other.artist == this.artist &&
          other.art == this.art &&
          other.albumId == this.albumId &&
          other.isStarred == this.isStarred);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> album;
  final Value<String> artist;
  final Value<String> art;
  final Value<int> albumId;
  final Value<bool> isStarred;

  const SongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.album = const Value.absent(),
    this.artist = const Value.absent(),
    this.art = const Value.absent(),
    this.albumId = const Value.absent(),
    this.isStarred = const Value.absent(),
  });

  SongsCompanion.insert({
    this.id = const Value.absent(),
    @required String title,
    @required String album,
    @required String artist,
    @required String art,
    @required int albumId,
    this.isStarred = const Value.absent(),
  })  : title = Value(title),
        album = Value(album),
        artist = Value(artist),
        art = Value(art),
        albumId = Value(albumId);

  static Insertable<Song> custom({
    Expression<int> id,
    Expression<String> title,
    Expression<String> album,
    Expression<String> artist,
    Expression<String> art,
    Expression<int> albumId,
    Expression<bool> isStarred,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (album != null) 'album': album,
      if (artist != null) 'artist': artist,
      if (art != null) 'art': art,
      if (albumId != null) 'album_id': albumId,
      if (isStarred != null) 'is_starred': isStarred,
    });
  }

  SongsCompanion copyWith(
      {Value<int> id,
      Value<String> title,
      Value<String> album,
      Value<String> artist,
      Value<String> art,
      Value<int> albumId,
      Value<bool> isStarred}) {
    return SongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      album: album ?? this.album,
      artist: artist ?? this.artist,
      art: art ?? this.art,
      albumId: albumId ?? this.albumId,
      isStarred: isStarred ?? this.isStarred,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (art.present) {
      map['art'] = Variable<String>(art.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<int>(albumId.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SongsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('album: $album, ')
          ..write('artist: $artist, ')
          ..write('art: $art, ')
          ..write('albumId: $albumId, ')
          ..write('isStarred: $isStarred')
          ..write(')'))
        .toString();
  }
}

class $SongsTable extends Songs with TableInfo<$SongsTable, Song> {
  final GeneratedDatabase _db;
  final String _alias;

  $SongsTable(this._db, [this._alias]);

  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;

  @override
  GeneratedIntColumn get id => _id ??= _constructId();

  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn(
      'id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _titleMeta = const VerificationMeta('title');
  GeneratedTextColumn _title;

  @override
  GeneratedTextColumn get title => _title ??= _constructTitle();

  GeneratedTextColumn _constructTitle() {
    return GeneratedTextColumn(
      'title',
      $tableName,
      false,
    );
  }

  final VerificationMeta _albumMeta = const VerificationMeta('album');
  GeneratedTextColumn _album;

  @override
  GeneratedTextColumn get album => _album ??= _constructAlbum();

  GeneratedTextColumn _constructAlbum() {
    return GeneratedTextColumn(
      'album',
      $tableName,
      false,
    );
  }

  final VerificationMeta _artistMeta = const VerificationMeta('artist');
  GeneratedTextColumn _artist;

  @override
  GeneratedTextColumn get artist => _artist ??= _constructArtist();

  GeneratedTextColumn _constructArtist() {
    return GeneratedTextColumn(
      'artist',
      $tableName,
      false,
    );
  }

  final VerificationMeta _artMeta = const VerificationMeta('art');
  GeneratedTextColumn _art;

  @override
  GeneratedTextColumn get art => _art ??= _constructArt();

  GeneratedTextColumn _constructArt() {
    return GeneratedTextColumn(
      'art',
      $tableName,
      false,
    );
  }

  final VerificationMeta _albumIdMeta = const VerificationMeta('albumId');
  GeneratedIntColumn _albumId;

  @override
  GeneratedIntColumn get albumId => _albumId ??= _constructAlbumId();

  GeneratedIntColumn _constructAlbumId() {
    return GeneratedIntColumn(
      'album_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _isStarredMeta = const VerificationMeta('isStarred');
  GeneratedBoolColumn _isStarred;

  @override
  GeneratedBoolColumn get isStarred => _isStarred ??= _constructIsStarred();

  GeneratedBoolColumn _constructIsStarred() {
    return GeneratedBoolColumn(
      'is_starred',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [id, title, album, artist, art, albumId, isStarred];

  @override
  $SongsTable get asDslTable => this;

  @override
  String get $tableName => _alias ?? 'songs';
  @override
  final String actualTableName = 'songs';

  @override
  VerificationContext validateIntegrity(Insertable<Song> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title'], _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('album')) {
      context.handle(
          _albumMeta, album.isAcceptableOrUnknown(data['album'], _albumMeta));
    } else if (isInserting) {
      context.missing(_albumMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(_artistMeta,
          artist.isAcceptableOrUnknown(data['artist'], _artistMeta));
    } else if (isInserting) {
      context.missing(_artistMeta);
    }
    if (data.containsKey('art')) {
      context.handle(
          _artMeta, art.isAcceptableOrUnknown(data['art'], _artMeta));
    } else if (isInserting) {
      context.missing(_artMeta);
    }
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id'], _albumIdMeta));
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('is_starred')) {
      context.handle(_isStarredMeta,
          isStarred.isAcceptableOrUnknown(data['is_starred'], _isStarredMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};

  @override
  Song map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return Song.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $SongsTable createAlias(String alias) {
    return $SongsTable(_db, alias);
  }
}

abstract class _$MoorDatabase extends GeneratedDatabase {
  _$MoorDatabase(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);

  _$MoorDatabase.connect(DatabaseConnection c) : super.connect(c);
  $AlbumsTable _albums;

  $AlbumsTable get albums => _albums ??= $AlbumsTable(this);
  $ArtistsTable _artists;

  $ArtistsTable get artists => _artists ??= $ArtistsTable(this);
  $SongsTable _songs;

  $SongsTable get songs => _songs ??= $SongsTable(this);
  AlbumsDao _albumsDao;

  AlbumsDao get albumsDao => _albumsDao ??= AlbumsDao(this as MoorDatabase);
  ArtistsDao _artistsDao;

  ArtistsDao get artistsDao => _artistsDao ??= ArtistsDao(this as MoorDatabase);
  SongsDao _songsDao;

  SongsDao get songsDao => _songsDao ??= SongsDao(this as MoorDatabase);

  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [albums, artists, songs];
}
