abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsSuccess extends SettingsState {
  final int prefetch;
  final bool isOffline;
  final int imageCacheSize;
  final int musicCacheSize;

  SettingsSuccess(
      {this.prefetch, this.isOffline, this.imageCacheSize, this.musicCacheSize});

  SettingsSuccess copyWith({
    int prefetch,
    bool isOffline,
    int imageCacheSize,
    int musicCacheSize,
  }) =>
      SettingsSuccess(
        prefetch: prefetch ?? this.prefetch,
        isOffline: isOffline ?? this.isOffline,
        imageCacheSize: imageCacheSize ?? this.imageCacheSize,
        musicCacheSize: musicCacheSize ?? this.musicCacheSize,
      );
}

class SettingsFailure extends SettingsState {}
