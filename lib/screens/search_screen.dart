import 'package:airstream/bloc/search_bloc.dart';
import 'package:airstream/data_providers/moor_database.dart';
import 'package:airstream/data_providers/repository/repository.dart';
import 'package:airstream/widgets/horizontal_album_grid.dart';
import 'package:airstream/widgets/horizontal_artist_grid.dart';
import 'package:airstream/widgets/song_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchScreen extends StatefulWidget {
  final GlobalKey<NavigatorState> navKey;

  const SearchScreen({Key key, this.navKey}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
	final textController = TextEditingController();

	@override
	Widget build(BuildContext context) {
		void _onTap(String route, dynamic argument) {
			final navState = widget.navKey.currentState;
			if (navState.canPop()) {
				navState.popUntil((route) => route.isFirst);
			}
			Navigator.pop(context);
			textController.clear();
			navState.pushNamed(route, arguments: argument);
		}

		return BlocProvider(
			create: (context) => SearchBloc(),
			child: Scaffold(
				body: SafeArea(
					child: Column(
						children: <Widget>[
							_SearchBar(textController: textController),
							Expanded(
								child: BlocBuilder<SearchBloc, SearchState>(
									builder: (context, state) {
										if (state is SearchSuccess) {
											return _OnSearchSuccess(state: state, onTap: _onTap);
										} else {
											return _OtherSearchStates(state: state);
										}
									},
								),
							),
						],
					),
				),
			),
		);
	}
}

class _SearchBar extends StatelessWidget {
	final TextEditingController textController;
	final bool isHidden;

	const _SearchBar({this.textController, this.isHidden});

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: const EdgeInsets.only(left: 8, right: 8, top: 10),
			child: Container(
				height: 55,
				padding: const EdgeInsets.symmetric(horizontal: 16),
				decoration: BoxDecoration(
					borderRadius: BorderRadius.circular(30),
					color: Theme
							.of(context)
							.cardColor,
				),
				child: Row(
					children: <Widget>[
						Icon(Icons.search),
						SizedBox(width: 35),
						Expanded(
							child: Padding(
								padding: const EdgeInsets.symmetric(vertical: 8),
								child: TextField(
									controller: textController,
									inputFormatters: <TextInputFormatter>[
										WhitelistingTextInputFormatter(RegExp("[a-zA-z ]"))
									],
									onChanged: (query) =>
											context.bloc<SearchBloc>().add(SearchQuery(query)),
									autofocus:
									textController.value.text.length == 0 ? true : false,
									maxLength: 25,
									decoration: InputDecoration(
										counterText: '',
										border: InputBorder.none,
										hintText: 'Search',
									),
								),
							),
						),
						RawMaterialButton(
							child: Icon(Icons.clear, color: Colors.white),
							shape: CircleBorder(),
							constraints: BoxConstraints.tightFor(width: 35, height: 35),
							onPressed: () {
								if (textController.value.text.length == 0) {
									Navigator.pop(context);
								} else {
									textController.clear();
									context.bloc<SearchBloc>().add(SearchQuery(''));
								}
							},
						),
					],
				),
			),
		);
	}
}

class _OnSearchSuccess extends StatelessWidget {
	final SearchSuccess state;
	final Function(String route, dynamic argument) onTap;

	const _OnSearchSuccess({Key key, @required this.state, this.onTap})
			: assert(state != null),
				super(key: key);

	@override
	Widget build(BuildContext context) {
		Widget _title(String title) {
			return SliverToBoxAdapter(
				child: Padding(
					padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
					child: Text(title, style: Theme
							.of(context)
							.textTheme
							.headline4),
				),
			);
		}

		List<Widget> _slivers() {
			final slivers = <Widget>[];

			if (state.artists.isNotEmpty) {
				slivers.addAll([
					_title('Artists'),
					SliverToBoxAdapter(
						child: HorizontalArtistGrid(
							artists: state.artists,
							onTap: (artist) {
								if (onTap != null) onTap('library/singleArtist', artist);
							},
						),
					),
				]);
			}

			if (state.albums.isNotEmpty) {
				slivers.addAll([
					_title('Albums'),
					SliverToBoxAdapter(
						child: HorizontalAlbumGrid(
							albums: state.albums,
							onTap: (album) {
								if (onTap != null) onTap('library/singleAlbum', album);
							},
						),
					),
				]);
			}

			if (state.songs.isNotEmpty) {
				slivers.addAll([
					_title('Songs'),
					_SongTiles(
						songs: state.songs,
						onTap: (song) async {
							final response = await Repository().album.byId(song.albumId);
							if (response.hasData && onTap != null) {
								onTap('library/singleAlbum', response.album);
							}
						},
					),
				]);
			}

			return slivers;
		}

		return CustomScrollView(
			physics: BouncingScrollPhysics(),
			slivers: _slivers(),
		);
	}
}

class _OtherSearchStates extends StatelessWidget {
	final SearchState state;

	const _OtherSearchStates({Key key, @required this.state})
			: assert(state != null),
				super(key: key);

	Widget _getStateText() {
		final currentState = state;
		if (currentState is SearchInitial) return Text('Here to serve!');
		if (currentState is SearchLoading) {
			return SizedBox(
				height: 60,
				width: 60,
				child: Center(child: CircularProgressIndicator()),
			);
		}
		if (currentState is SearchFailure) return Text('Found no results.');
		// If no state could be found
		return Text('Could not read state.');
	}

	@override
	Widget build(BuildContext context) {
		return Center(
			child: SingleChildScrollView(
				child: _getStateText(),
			),
		);
	}
}

class _SongTiles extends StatelessWidget {
	final List<Song> songs;
	final Function(Song) onTap;

	const _SongTiles({Key key, this.songs, this.onTap}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return SliverList(delegate: SliverChildBuilderDelegate((context, index) {
			return SongTile(
				song: songs[index],
				onTap: () => onTap != null ? onTap(songs[index]) : null,
			);
		}, childCount: songs.length,));
	}
}