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
  final bool isCached;
  final bool isStarred;
  Album(
      {@required this.id,
      @required this.title,
      @required this.artist,
      @required this.artistId,
      @required this.songCount,
      this.art,
      @required this.created,
      this.genre,
      this.year,
      @required this.isCached,
      @required this.isStarred});
  factory Album.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    final boolType = db.typeSystem.forDartType<bool>();
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
      isCached:
          boolType.mapFromDatabaseResponse(data['${effectivePrefix}is_cached']),
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
    if (!nullToAbsent || isCached != null) {
      map['is_cached'] = Variable<bool>(isCached);
    }
    if (!nullToAbsent || isStarred != null) {
      map['is_starred'] = Variable<bool>(isStarred);
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
      isCached: isCached == null && nullToAbsent
          ? const Value.absent()
          : Value(isCached),
      isStarred: isStarred == null && nullToAbsent
          ? const Value.absent()
          : Value(isStarred),
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
      isCached: serializer.fromJson<bool>(json['isCached']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
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
      'isCached': serializer.toJson<bool>(isCached),
      'isStarred': serializer.toJson<bool>(isStarred),
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
          int year,
          bool isCached,
          bool isStarred}) =>
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
        isCached: isCached ?? this.isCached,
        isStarred: isStarred ?? this.isStarred,
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
          ..write('year: $year, ')
          ..write('isCached: $isCached, ')
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
              artist.hashCode,
              $mrjc(
                  artistId.hashCode,
                  $mrjc(
                      songCount.hashCode,
                      $mrjc(
                          art.hashCode,
                          $mrjc(
                              created.hashCode,
                              $mrjc(
                                  genre.hashCode,
                                  $mrjc(
                                      year.hashCode,
                                      $mrjc(isCached.hashCode,
                                          isStarred.hashCode)))))))))));
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
          other.year == this.year &&
          other.isCached == this.isCached &&
          other.isStarred == this.isStarred);
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
  final Value<bool> isCached;
  final Value<bool> isStarred;
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
    this.isCached = const Value.absent(),
    this.isStarred = const Value.absent(),
  });
  AlbumsCompanion.insert({
    this.id = const Value.absent(),
    @required String title,
    @required String artist,
    @required int artistId,
    @required int songCount,
    this.art = const Value.absent(),
    @required DateTime created,
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.isCached = const Value.absent(),
    this.isStarred = const Value.absent(),
  })  : title = Value(title),
        artist = Value(artist),
        artistId = Value(artistId),
        songCount = Value(songCount),
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
    Expression<bool> isCached,
    Expression<bool> isStarred,
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
      if (isCached != null) 'is_cached': isCached,
      if (isStarred != null) 'is_starred': isStarred,
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
      Value<int> year,
      Value<bool> isCached,
      Value<bool> isStarred}) {
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
      isCached: isCached ?? this.isCached,
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
    if (isCached.present) {
      map['is_cached'] = Variable<bool>(isCached.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
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
          ..write('year: $year, ')
          ..write('isCached: $isCached, ')
          ..write('isStarred: $isStarred')
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
      true,
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

  final VerificationMeta _isCachedMeta = const VerificationMeta('isCached');
  GeneratedBoolColumn _isCached;
  @override
  GeneratedBoolColumn get isCached => _isCached ??= _constructIsCached();
  GeneratedBoolColumn _constructIsCached() {
    return GeneratedBoolColumn('is_cached', $tableName, false,
        defaultValue: const Constant(false));
  }

  final VerificationMeta _isStarredMeta = const VerificationMeta('isStarred');
  GeneratedBoolColumn _isStarred;
  @override
  GeneratedBoolColumn get isStarred => _isStarred ??= _constructIsStarred();
  GeneratedBoolColumn _constructIsStarred() {
    return GeneratedBoolColumn('is_starred', $tableName, false,
        defaultValue: const Constant(false));
  }

  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        artist,
        artistId,
        songCount,
        art,
        created,
        genre,
        year,
        isCached,
        isStarred
      ];
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
    if (data.containsKey('is_cached')) {
      context.handle(_isCachedMeta,
          isCached.isAcceptableOrUnknown(data['is_cached'], _isCachedMeta));
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
  final Uint8List similar;
  Artist(
      {@required this.id,
      @required this.name,
      @required this.albumCount,
      this.art,
      this.similar});
  factory Artist.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final uint8ListType = db.typeSystem.forDartType<Uint8List>();
    return Artist(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      name: stringType.mapFromDatabaseResponse(data['${effectivePrefix}name']),
      albumCount: intType
          .mapFromDatabaseResponse(data['${effectivePrefix}album_count']),
      art: stringType.mapFromDatabaseResponse(data['${effectivePrefix}art']),
      similar: uint8ListType
          .mapFromDatabaseResponse(data['${effectivePrefix}similar']),
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
    if (!nullToAbsent || similar != null) {
      map['similar'] = Variable<Uint8List>(similar);
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
      similar: similar == null && nullToAbsent
          ? const Value.absent()
          : Value(similar),
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
      similar: serializer.fromJson<Uint8List>(json['similar']),
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
      'similar': serializer.toJson<Uint8List>(similar),
    };
  }

  Artist copyWith(
          {int id,
          String name,
          int albumCount,
          String art,
          Uint8List similar}) =>
      Artist(
        id: id ?? this.id,
        name: name ?? this.name,
        albumCount: albumCount ?? this.albumCount,
        art: art ?? this.art,
        similar: similar ?? this.similar,
      );
  @override
  String toString() {
    return (StringBuffer('Artist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('albumCount: $albumCount, ')
          ..write('art: $art, ')
          ..write('similar: $similar')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(name.hashCode,
          $mrjc(albumCount.hashCode, $mrjc(art.hashCode, similar.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is Artist &&
          other.id == this.id &&
          other.name == this.name &&
          other.albumCount == this.albumCount &&
          other.art == this.art &&
          other.similar == this.similar);
}

class ArtistsCompanion extends UpdateCompanion<Artist> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> albumCount;
  final Value<String> art;
  final Value<Uint8List> similar;
  const ArtistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.albumCount = const Value.absent(),
    this.art = const Value.absent(),
    this.similar = const Value.absent(),
  });
  ArtistsCompanion.insert({
    this.id = const Value.absent(),
    @required String name,
    @required int albumCount,
    this.art = const Value.absent(),
    this.similar = const Value.absent(),
  })  : name = Value(name),
        albumCount = Value(albumCount);
  static Insertable<Artist> custom({
    Expression<int> id,
    Expression<String> name,
    Expression<int> albumCount,
    Expression<String> art,
    Expression<Uint8List> similar,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (albumCount != null) 'album_count': albumCount,
      if (art != null) 'art': art,
      if (similar != null) 'similar': similar,
    });
  }

  ArtistsCompanion copyWith(
      {Value<int> id,
      Value<String> name,
      Value<int> albumCount,
      Value<String> art,
      Value<Uint8List> similar}) {
    return ArtistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      albumCount: albumCount ?? this.albumCount,
      art: art ?? this.art,
      similar: similar ?? this.similar,
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
    if (similar.present) {
      map['similar'] = Variable<Uint8List>(similar.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('albumCount: $albumCount, ')
          ..write('art: $art, ')
          ..write('similar: $similar')
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
      true,
    );
  }

  final VerificationMeta _similarMeta = const VerificationMeta('similar');
  GeneratedBlobColumn _similar;
  @override
  GeneratedBlobColumn get similar => _similar ??= _constructSimilar();
  GeneratedBlobColumn _constructSimilar() {
    return GeneratedBlobColumn(
      'similar',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns => [id, name, albumCount, art, similar];
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
    }
    if (data.containsKey('similar')) {
      context.handle(_similarMeta,
          similar.isAcceptableOrUnknown(data['similar'], _similarMeta));
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
  final String topSongKey;
  final String filename;
  Song(
      {@required this.id,
      @required this.title,
      @required this.album,
      @required this.artist,
      this.art,
      @required this.albumId,
      @required this.isStarred,
      this.topSongKey,
      this.filename});
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
      topSongKey: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}top_song_key']),
      filename: stringType
          .mapFromDatabaseResponse(data['${effectivePrefix}filename']),
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
    if (!nullToAbsent || topSongKey != null) {
      map['top_song_key'] = Variable<String>(topSongKey);
    }
    if (!nullToAbsent || filename != null) {
      map['filename'] = Variable<String>(filename);
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
      topSongKey: topSongKey == null && nullToAbsent
          ? const Value.absent()
          : Value(topSongKey),
      filename: filename == null && nullToAbsent
          ? const Value.absent()
          : Value(filename),
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
      topSongKey: serializer.fromJson<String>(json['topSongKey']),
      filename: serializer.fromJson<String>(json['filename']),
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
      'topSongKey': serializer.toJson<String>(topSongKey),
      'filename': serializer.toJson<String>(filename),
    };
  }

  Song copyWith(
          {int id,
          String title,
          String album,
          String artist,
          String art,
          int albumId,
          bool isStarred,
          String topSongKey,
          String filename}) =>
      Song(
        id: id ?? this.id,
        title: title ?? this.title,
        album: album ?? this.album,
        artist: artist ?? this.artist,
        art: art ?? this.art,
        albumId: albumId ?? this.albumId,
        isStarred: isStarred ?? this.isStarred,
        topSongKey: topSongKey ?? this.topSongKey,
        filename: filename ?? this.filename,
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
          ..write('isStarred: $isStarred, ')
          ..write('topSongKey: $topSongKey, ')
          ..write('filename: $filename')
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
                  $mrjc(
                      art.hashCode,
                      $mrjc(
                          albumId.hashCode,
                          $mrjc(
                              isStarred.hashCode,
                              $mrjc(topSongKey.hashCode,
                                  filename.hashCode)))))))));
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
          other.isStarred == this.isStarred &&
          other.topSongKey == this.topSongKey &&
          other.filename == this.filename);
}

class SongsCompanion extends UpdateCompanion<Song> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> album;
  final Value<String> artist;
  final Value<String> art;
  final Value<int> albumId;
  final Value<bool> isStarred;
  final Value<String> topSongKey;
  final Value<String> filename;
  const SongsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.album = const Value.absent(),
    this.artist = const Value.absent(),
    this.art = const Value.absent(),
    this.albumId = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.topSongKey = const Value.absent(),
    this.filename = const Value.absent(),
  });
  SongsCompanion.insert({
    this.id = const Value.absent(),
    @required String title,
    @required String album,
    @required String artist,
    this.art = const Value.absent(),
    @required int albumId,
    this.isStarred = const Value.absent(),
    this.topSongKey = const Value.absent(),
    this.filename = const Value.absent(),
  })  : title = Value(title),
        album = Value(album),
        artist = Value(artist),
        albumId = Value(albumId);
  static Insertable<Song> custom({
    Expression<int> id,
    Expression<String> title,
    Expression<String> album,
    Expression<String> artist,
    Expression<String> art,
    Expression<int> albumId,
    Expression<bool> isStarred,
    Expression<String> topSongKey,
    Expression<String> filename,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (album != null) 'album': album,
      if (artist != null) 'artist': artist,
      if (art != null) 'art': art,
      if (albumId != null) 'album_id': albumId,
      if (isStarred != null) 'is_starred': isStarred,
      if (topSongKey != null) 'top_song_key': topSongKey,
      if (filename != null) 'filename': filename,
    });
  }

  SongsCompanion copyWith(
      {Value<int> id,
      Value<String> title,
      Value<String> album,
      Value<String> artist,
      Value<String> art,
      Value<int> albumId,
      Value<bool> isStarred,
      Value<String> topSongKey,
      Value<String> filename}) {
    return SongsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      album: album ?? this.album,
      artist: artist ?? this.artist,
      art: art ?? this.art,
      albumId: albumId ?? this.albumId,
      isStarred: isStarred ?? this.isStarred,
      topSongKey: topSongKey ?? this.topSongKey,
      filename: filename ?? this.filename,
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
    if (topSongKey.present) {
      map['top_song_key'] = Variable<String>(topSongKey.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
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
          ..write('isStarred: $isStarred, ')
          ..write('topSongKey: $topSongKey, ')
          ..write('filename: $filename')
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
      true,
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
    return GeneratedBoolColumn('is_starred', $tableName, false,
        defaultValue: const Constant(false));
  }

  final VerificationMeta _topSongKeyMeta = const VerificationMeta('topSongKey');
  GeneratedTextColumn _topSongKey;
  @override
  GeneratedTextColumn get topSongKey => _topSongKey ??= _constructTopSongKey();
  GeneratedTextColumn _constructTopSongKey() {
    return GeneratedTextColumn(
      'top_song_key',
      $tableName,
      true,
    );
  }

  final VerificationMeta _filenameMeta = const VerificationMeta('filename');
  GeneratedTextColumn _filename;
  @override
  GeneratedTextColumn get filename => _filename ??= _constructFilename();
  GeneratedTextColumn _constructFilename() {
    return GeneratedTextColumn(
      'filename',
      $tableName,
      true,
    );
  }

  @override
  List<GeneratedColumn> get $columns =>
      [id, title, album, artist, art, albumId, isStarred, topSongKey, filename];
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
    if (data.containsKey('top_song_key')) {
      context.handle(
          _topSongKeyMeta,
          topSongKey.isAcceptableOrUnknown(
              data['top_song_key'], _topSongKeyMeta));
    }
    if (data.containsKey('filename')) {
      context.handle(_filenameMeta,
          filename.isAcceptableOrUnknown(data['filename'], _filenameMeta));
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

class AudioFile extends DataClass implements Insertable<AudioFile> {
  final int songId;
  final String path;
  final int size;
  final DateTime created;
  AudioFile(
      {@required this.songId,
      @required this.path,
      @required this.size,
      @required this.created});
  factory AudioFile.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    final dateTimeType = db.typeSystem.forDartType<DateTime>();
    return AudioFile(
      songId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}song_id']),
      path: stringType.mapFromDatabaseResponse(data['${effectivePrefix}path']),
      size: intType.mapFromDatabaseResponse(data['${effectivePrefix}size']),
      created: dateTimeType
          .mapFromDatabaseResponse(data['${effectivePrefix}created']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || songId != null) {
      map['song_id'] = Variable<int>(songId);
    }
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<int>(size);
    }
    if (!nullToAbsent || created != null) {
      map['created'] = Variable<DateTime>(created);
    }
    return map;
  }

  AudioFilesCompanion toCompanion(bool nullToAbsent) {
    return AudioFilesCompanion(
      songId:
          songId == null && nullToAbsent ? const Value.absent() : Value(songId),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      created: created == null && nullToAbsent
          ? const Value.absent()
          : Value(created),
    );
  }

  factory AudioFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return AudioFile(
      songId: serializer.fromJson<int>(json['songId']),
      path: serializer.fromJson<String>(json['path']),
      size: serializer.fromJson<int>(json['size']),
      created: serializer.fromJson<DateTime>(json['created']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'songId': serializer.toJson<int>(songId),
      'path': serializer.toJson<String>(path),
      'size': serializer.toJson<int>(size),
      'created': serializer.toJson<DateTime>(created),
    };
  }

  AudioFile copyWith({int songId, String path, int size, DateTime created}) =>
      AudioFile(
        songId: songId ?? this.songId,
        path: path ?? this.path,
        size: size ?? this.size,
        created: created ?? this.created,
      );
  @override
  String toString() {
    return (StringBuffer('AudioFile(')
          ..write('songId: $songId, ')
          ..write('path: $path, ')
          ..write('size: $size, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(songId.hashCode,
      $mrjc(path.hashCode, $mrjc(size.hashCode, created.hashCode))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is AudioFile &&
          other.songId == this.songId &&
          other.path == this.path &&
          other.size == this.size &&
          other.created == this.created);
}

class AudioFilesCompanion extends UpdateCompanion<AudioFile> {
  final Value<int> songId;
  final Value<String> path;
  final Value<int> size;
  final Value<DateTime> created;
  const AudioFilesCompanion({
    this.songId = const Value.absent(),
    this.path = const Value.absent(),
    this.size = const Value.absent(),
    this.created = const Value.absent(),
  });
  AudioFilesCompanion.insert({
    this.songId = const Value.absent(),
    @required String path,
    @required int size,
    @required DateTime created,
  })  : path = Value(path),
        size = Value(size),
        created = Value(created);
  static Insertable<AudioFile> custom({
    Expression<int> songId,
    Expression<String> path,
    Expression<int> size,
    Expression<DateTime> created,
  }) {
    return RawValuesInsertable({
      if (songId != null) 'song_id': songId,
      if (path != null) 'path': path,
      if (size != null) 'size': size,
      if (created != null) 'created': created,
    });
  }

  AudioFilesCompanion copyWith(
      {Value<int> songId,
      Value<String> path,
      Value<int> size,
      Value<DateTime> created}) {
    return AudioFilesCompanion(
      songId: songId ?? this.songId,
      path: path ?? this.path,
      size: size ?? this.size,
      created: created ?? this.created,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioFilesCompanion(')
          ..write('songId: $songId, ')
          ..write('path: $path, ')
          ..write('size: $size, ')
          ..write('created: $created')
          ..write(')'))
        .toString();
  }
}

class $AudioFilesTable extends AudioFiles
    with TableInfo<$AudioFilesTable, AudioFile> {
  final GeneratedDatabase _db;
  final String _alias;
  $AudioFilesTable(this._db, [this._alias]);
  final VerificationMeta _songIdMeta = const VerificationMeta('songId');
  GeneratedIntColumn _songId;
  @override
  GeneratedIntColumn get songId => _songId ??= _constructSongId();
  GeneratedIntColumn _constructSongId() {
    return GeneratedIntColumn('song_id', $tableName, false,
        $customConstraints: 'REFERENCES songs(id)');
  }

  final VerificationMeta _pathMeta = const VerificationMeta('path');
  GeneratedTextColumn _path;
  @override
  GeneratedTextColumn get path => _path ??= _constructPath();
  GeneratedTextColumn _constructPath() {
    return GeneratedTextColumn(
      'path',
      $tableName,
      false,
    );
  }

  final VerificationMeta _sizeMeta = const VerificationMeta('size');
  GeneratedIntColumn _size;
  @override
  GeneratedIntColumn get size => _size ??= _constructSize();
  GeneratedIntColumn _constructSize() {
    return GeneratedIntColumn(
      'size',
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

  @override
  List<GeneratedColumn> get $columns => [songId, path, size, created];
  @override
  $AudioFilesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'audio_files';
  @override
  final String actualTableName = 'audio_files';
  @override
  VerificationContext validateIntegrity(Insertable<AudioFile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('song_id')) {
      context.handle(_songIdMeta,
          songId.isAcceptableOrUnknown(data['song_id'], _songIdMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path'], _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size'], _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('created')) {
      context.handle(_createdMeta,
          created.isAcceptableOrUnknown(data['created'], _createdMeta));
    } else if (isInserting) {
      context.missing(_createdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {songId};
  @override
  AudioFile map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return AudioFile.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $AudioFilesTable createAlias(String alias) {
    return $AudioFilesTable(_db, alias);
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
  $AudioFilesTable _audioFiles;
  $AudioFilesTable get audioFiles => _audioFiles ??= $AudioFilesTable(this);
  AlbumsDao _albumsDao;
  AlbumsDao get albumsDao => _albumsDao ??= AlbumsDao(this as MoorDatabase);
  ArtistsDao _artistsDao;
  ArtistsDao get artistsDao => _artistsDao ??= ArtistsDao(this as MoorDatabase);
  SongsDao _songsDao;
  SongsDao get songsDao => _songsDao ??= SongsDao(this as MoorDatabase);
  AudioFilesDao _audioFilesDao;
  AudioFilesDao get audioFilesDao =>
      _audioFilesDao ??= AudioFilesDao(this as MoorDatabase);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [albums, artists, songs, audioFiles];
}
