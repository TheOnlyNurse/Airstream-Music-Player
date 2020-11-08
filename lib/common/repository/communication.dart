// Enums used as communication
enum SongChange { unStarred, starred }
enum PlaylistChange { songsRemoved, songsAdded, fetched }
enum AudioPlayerState { playing, paused, stopped }
enum AudioPlayerSongState { newSong }
enum SettingType {
  prefetch,
  isOffline,
  imageCache,
  musicCache,
  wifiBitrate,
  mobileBitrate,
  autoOffline,
}
enum AlbumLibrary {
  random,
  newlyAdded,
  recent,
  frequent,
  byAlphabet,
  byGenre,
  byDecade,
  search,
  byArtist,
}
