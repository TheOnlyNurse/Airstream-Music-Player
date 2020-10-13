// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moor_cache.dart';

// **************************************************************************
// MoorGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps, unnecessary_this
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
  $AudioFilesTable _audioFiles;
  $AudioFilesTable get audioFiles => _audioFiles ??= $AudioFilesTable(this);
  AudioFilesDao _audioFilesDao;
  AudioFilesDao get audioFilesDao =>
      _audioFilesDao ??= AudioFilesDao(this as MoorCache);
  @override
  Iterable<TableInfo> get allTables => allSchemaEntities.whereType<TableInfo>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [audioFiles];
}
