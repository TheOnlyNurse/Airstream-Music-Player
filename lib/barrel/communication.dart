// Enums used as communication
enum SongChange { unstarred, starred }
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
  mobileOffline,
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
