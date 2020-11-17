part of 'artist_bloc.dart';

abstract class SingleArtistState extends Equatable {
  const SingleArtistState() : super();

  @override
  List<Object> get props => [];
}

class SingleArtistInitial extends SingleArtistState {}

class SingleArtistSuccess extends SingleArtistState {
  const SingleArtistSuccess(
    this.artist, {
    this.songs,
    this.albums,
    this.similarArtists,
    this.image,
  });

  final Artist artist;
  final List<Song> songs;
  final List<Album> albums;
  final List<Artist> similarArtists;
  final File image;

  SingleArtistSuccess copyWith({
    List<Album> albums,
    List<Song> songs,
    List<Artist> similarArtists,
    File image,
  }) =>
      SingleArtistSuccess(
        artist,
        songs: songs ?? this.songs,
        albums: albums ?? this.albums,
        similarArtists: similarArtists ?? this.similarArtists,
        image: image ?? this.image,
      );

  @override
  List<Object> get props => [songs, albums, similarArtists, image];
}

class SingleArtistFailure extends SingleArtistState {
  const SingleArtistFailure(this.error);

  final String error;
}
