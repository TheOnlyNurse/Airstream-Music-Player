// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_cache.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
class ImageFile extends DataClass implements Insertable<ImageFile> {
  final int id;
  final String artId;
  final String type;
  final String path;
  final int size;
  ImageFile(
      {@required this.id,
      @required this.artId,
      @required this.type,
      this.path,
      @required this.size});
  factory ImageFile.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final intType = db.typeSystem.forDartType<int>();
    final stringType = db.typeSystem.forDartType<String>();
    return ImageFile(
      id: intType.mapFromDatabaseResponse(data['${effectivePrefix}id']),
      artId:
          stringType.mapFromDatabaseResponse(data['${effectivePrefix}art_id']),
      type: stringType.mapFromDatabaseResponse(data['${effectivePrefix}type']),
      path: stringType.mapFromDatabaseResponse(data['${effectivePrefix}path']),
      size: intType.mapFromDatabaseResponse(data['${effectivePrefix}size']),
    );
  }
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<int>(id);
    }
    if (!nullToAbsent || artId != null) {
      map['art_id'] = Variable<String>(artId);
    }
    if (!nullToAbsent || type != null) {
      map['type'] = Variable<String>(type);
    }
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<int>(size);
    }
    return map;
  }

  ImageFilesCompanion toCompanion(bool nullToAbsent) {
    return ImageFilesCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      artId:
          artId == null && nullToAbsent ? const Value.absent() : Value(artId),
      type: type == null && nullToAbsent ? const Value.absent() : Value(type),
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
    );
  }

  factory ImageFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return ImageFile(
      id: serializer.fromJson<int>(json['id']),
      artId: serializer.fromJson<String>(json['artId']),
      type: serializer.fromJson<String>(json['type']),
      path: serializer.fromJson<String>(json['path']),
      size: serializer.fromJson<int>(json['size']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'artId': serializer.toJson<String>(artId),
      'type': serializer.toJson<String>(type),
      'path': serializer.toJson<String>(path),
      'size': serializer.toJson<int>(size),
    };
  }

  ImageFile copyWith(
          {int id, String artId, String type, String path, int size}) =>
      ImageFile(
        id: id ?? this.id,
        artId: artId ?? this.artId,
        type: type ?? this.type,
        path: path ?? this.path,
        size: size ?? this.size,
      );
  @override
  String toString() {
    return (StringBuffer('ImageFile(')
          ..write('id: $id, ')
          ..write('artId: $artId, ')
          ..write('type: $type, ')
          ..write('path: $path, ')
          ..write('size: $size')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(
      id.hashCode,
      $mrjc(artId.hashCode,
          $mrjc(type.hashCode, $mrjc(path.hashCode, size.hashCode)))));
  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is ImageFile &&
          other.id == this.id &&
          other.artId == this.artId &&
          other.type == this.type &&
          other.path == this.path &&
          other.size == this.size);
}

class ImageFilesCompanion extends UpdateCompanion<ImageFile> {
  final Value<int> id;
  final Value<String> artId;
  final Value<String> type;
  final Value<String> path;
  final Value<int> size;
  const ImageFilesCompanion({
    this.id = const Value.absent(),
    this.artId = const Value.absent(),
    this.type = const Value.absent(),
    this.path = const Value.absent(),
    this.size = const Value.absent(),
  });
  ImageFilesCompanion.insert({
    this.id = const Value.absent(),
    @required String artId,
    @required String type,
    this.path = const Value.absent(),
    @required int size,
  })  : artId = Value(artId),
        type = Value(type),
        size = Value(size);
  static Insertable<ImageFile> custom({
    Expression<int> id,
    Expression<String> artId,
    Expression<String> type,
    Expression<String> path,
    Expression<int> size,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (artId != null) 'art_id': artId,
      if (type != null) 'type': type,
      if (path != null) 'path': path,
      if (size != null) 'size': size,
    });
  }

  ImageFilesCompanion copyWith(
      {Value<int> id,
      Value<String> artId,
      Value<String> type,
      Value<String> path,
      Value<int> size}) {
    return ImageFilesCompanion(
      id: id ?? this.id,
      artId: artId ?? this.artId,
      type: type ?? this.type,
      path: path ?? this.path,
      size: size ?? this.size,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (artId.present) {
      map['art_id'] = Variable<String>(artId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImageFilesCompanion(')
          ..write('id: $id, ')
          ..write('artId: $artId, ')
          ..write('type: $type, ')
          ..write('path: $path, ')
          ..write('size: $size')
          ..write(')'))
        .toString();
  }
}

class $ImageFilesTable extends ImageFiles
    with TableInfo<$ImageFilesTable, ImageFile> {
  final GeneratedDatabase _db;
  final String _alias;
  $ImageFilesTable(this._db, [this._alias]);
  final VerificationMeta _idMeta = const VerificationMeta('id');
  GeneratedIntColumn _id;
  @override
  GeneratedIntColumn get id => _id ??= _constructId();
  GeneratedIntColumn _constructId() {
    return GeneratedIntColumn('id', $tableName, false,
        hasAutoIncrement: true, declaredAsPrimaryKey: true);
  }

  final VerificationMeta _artIdMeta = const VerificationMeta('artId');
  GeneratedTextColumn _artId;
  @override
  GeneratedTextColumn get artId => _artId ??= _constructArtId();
  GeneratedTextColumn _constructArtId() {
    return GeneratedTextColumn(
      'art_id',
      $tableName,
      false,
    );
  }

  final VerificationMeta _typeMeta = const VerificationMeta('type');
  GeneratedTextColumn _type;
  @override
  GeneratedTextColumn get type => _type ??= _constructType();
  GeneratedTextColumn _constructType() {
    return GeneratedTextColumn(
      'type',
      $tableName,
      false,
    );
  }

  final VerificationMeta _pathMeta = const VerificationMeta('path');
  GeneratedTextColumn _path;
  @override
  GeneratedTextColumn get path => _path ??= _constructPath();
  GeneratedTextColumn _constructPath() {
    return GeneratedTextColumn(
      'path',
      $tableName,
      true,
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

  @override
  List<GeneratedColumn> get $columns => [id, artId, type, path, size];
  @override
  $ImageFilesTable get asDslTable => this;
  @override
  String get $tableName => _alias ?? 'image_files';
  @override
  final String actualTableName = 'image_files';
  @override
  VerificationContext validateIntegrity(Insertable<ImageFile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id'], _idMeta));
    }
    if (data.containsKey('art_id')) {
      context.handle(
          _artIdMeta, artId.isAcceptableOrUnknown(data['art_id'], _artIdMeta));
    } else if (isInserting) {
      context.missing(_artIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type'], _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path'], _pathMeta));
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size'], _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImageFile map(Map<String, dynamic> data, {String tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : null;
    return ImageFile.fromData(data, _db, prefix: effectivePrefix);
  }

  @override
  $ImageFilesTable createAlias(String alias) {
    return $ImageFilesTable(_db, alias);
  }
}

class AudioFile extends DataClass implements Insertable<AudioFile> {
  final String path;
  final int songId;
  final int albumId;
  final int size;

  AudioFile(
      {@required this.path,
      @required this.songId,
      @required this.albumId,
      @required this.size});

  factory AudioFile.fromData(Map<String, dynamic> data, GeneratedDatabase db,
      {String prefix}) {
    final effectivePrefix = prefix ?? '';
    final stringType = db.typeSystem.forDartType<String>();
    final intType = db.typeSystem.forDartType<int>();
    return AudioFile(
      path: stringType.mapFromDatabaseResponse(data['${effectivePrefix}path']),
      songId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}song_id']),
      albumId:
          intType.mapFromDatabaseResponse(data['${effectivePrefix}album_id']),
      size: intType.mapFromDatabaseResponse(data['${effectivePrefix}size']),
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || path != null) {
      map['path'] = Variable<String>(path);
    }
    if (!nullToAbsent || songId != null) {
      map['song_id'] = Variable<int>(songId);
    }
    if (!nullToAbsent || albumId != null) {
      map['album_id'] = Variable<int>(albumId);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<int>(size);
    }
    return map;
  }

  AudioFilesCompanion toCompanion(bool nullToAbsent) {
    return AudioFilesCompanion(
      path: path == null && nullToAbsent ? const Value.absent() : Value(path),
      songId:
          songId == null && nullToAbsent ? const Value.absent() : Value(songId),
      albumId: albumId == null && nullToAbsent
          ? const Value.absent()
          : Value(albumId),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
    );
  }

  factory AudioFile.fromJson(Map<String, dynamic> json,
      {ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return AudioFile(
      path: serializer.fromJson<String>(json['path']),
      songId: serializer.fromJson<int>(json['songId']),
      albumId: serializer.fromJson<int>(json['albumId']),
      size: serializer.fromJson<int>(json['size']),
    );
  }

  @override
  Map<String, dynamic> toJson({ValueSerializer serializer}) {
    serializer ??= moorRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'path': serializer.toJson<String>(path),
      'songId': serializer.toJson<int>(songId),
      'albumId': serializer.toJson<int>(albumId),
      'size': serializer.toJson<int>(size),
    };
  }

  AudioFile copyWith({String path, int songId, int albumId, int size}) =>
      AudioFile(
        path: path ?? this.path,
        songId: songId ?? this.songId,
        albumId: albumId ?? this.albumId,
        size: size ?? this.size,
      );

  @override
  String toString() {
    return (StringBuffer('AudioFile(')
          ..write('path: $path, ')
          ..write('songId: $songId, ')
          ..write('albumId: $albumId, ')
          ..write('size: $size')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => $mrjf($mrjc(path.hashCode,
      $mrjc(songId.hashCode, $mrjc(albumId.hashCode, size.hashCode))));

  @override
  bool operator ==(dynamic other) =>
      identical(this, other) ||
      (other is AudioFile &&
          other.path == this.path &&
          other.songId == this.songId &&
          other.albumId == this.albumId &&
          other.size == this.size);
}

class AudioFilesCompanion extends UpdateCompanion<AudioFile> {
  final Value<String> path;
  final Value<int> songId;
  final Value<int> albumId;
  final Value<int> size;

  const AudioFilesCompanion({
    this.path = const Value.absent(),
    this.songId = const Value.absent(),
    this.albumId = const Value.absent(),
    this.size = const Value.absent(),
  });

  AudioFilesCompanion.insert({
    @required String path,
    this.songId = const Value.absent(),
    @required int albumId,
    @required int size,
  })  : path = Value(path),
        albumId = Value(albumId),
        size = Value(size);

  static Insertable<AudioFile> custom({
    Expression<String> path,
    Expression<int> songId,
    Expression<int> albumId,
    Expression<int> size,
  }) {
    return RawValuesInsertable({
      if (path != null) 'path': path,
      if (songId != null) 'song_id': songId,
      if (albumId != null) 'album_id': albumId,
      if (size != null) 'size': size,
    });
  }

  AudioFilesCompanion copyWith(
      {Value<String> path,
      Value<int> songId,
      Value<int> albumId,
      Value<int> size}) {
    return AudioFilesCompanion(
      path: path ?? this.path,
      songId: songId ?? this.songId,
      albumId: albumId ?? this.albumId,
      size: size ?? this.size,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (songId.present) {
      map['song_id'] = Variable<int>(songId.value);
    }
    if (albumId.present) {
      map['album_id'] = Variable<int>(albumId.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AudioFilesCompanion(')
          ..write('path: $path, ')
          ..write('songId: $songId, ')
          ..write('albumId: $albumId, ')
          ..write('size: $size')
          ..write(')'))
        .toString();
  }
}

class $AudioFilesTable extends AudioFiles
    with TableInfo<$AudioFilesTable, AudioFile> {
  final GeneratedDatabase _db;
  final String _alias;

  $AudioFilesTable(this._db, [this._alias]);

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

  final VerificationMeta _songIdMeta = const VerificationMeta('songId');
  GeneratedIntColumn _songId;

  @override
  GeneratedIntColumn get songId => _songId ??= _constructSongId();

  GeneratedIntColumn _constructSongId() {
    return GeneratedIntColumn(
      'song_id',
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

  @override
  List<GeneratedColumn> get $columns => [path, songId, albumId, size];

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
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path'], _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('song_id')) {
      context.handle(_songIdMeta,
          songId.isAcceptableOrUnknown(data['song_id'], _songIdMeta));
    }
    if (data.containsKey('album_id')) {
      context.handle(_albumIdMeta,
          albumId.isAcceptableOrUnknown(data['album_id'], _albumIdMeta));
    } else if (isInserting) {
      context.missing(_albumIdMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
          _sizeMeta, size.isAcceptableOrUnknown(data['size'], _sizeMeta));
    } else if (isInserting) {
      context.missing(_sizeMeta);
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

abstract class _$MoorCache extends GeneratedDatabase {
  _$MoorCache(QueryExecutor e) : super(SqlTypeSystem.defaultInstance, e);

  _$MoorCache.connect(DatabaseConnection c) : super.connect(c);
  $ImageFilesTable _imageFiles;

  $ImageFilesTable get imageFiles => _imageFiles ??= $ImageFilesTable(this);
  $AudioFilesTable _audioFiles;

  $AudioFilesTable get audioFiles => _audioFiles ??= $AudioFilesTable(this);
  ImageFilesDao _imageFilesDao;

  ImageFilesDao get imageFilesDao =>
      _imageFilesDao ??= ImageFilesDao(this as MoorCache);
  AudioFilesDao _audioFilesDao;

  AudioFilesDao get audioFilesDao =>
      _audioFilesDao ??= AudioFilesDao(this as MoorCache);

  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [imageFiles, audioFiles];
}
