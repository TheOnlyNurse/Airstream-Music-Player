import 'package:airstream/barrel/repository_subdivision_tools.dart';
import 'package:airstream/data_providers/settings_provider.dart';

class SettingsRepository {
	Future<RepoSettingsContainer> get() async {
		final provider = SettingsProvider();
		return RepoSettingsContainer(
			prefetch: await provider.prefetchValue,
			isOffline: await provider.isOffline,
			imageCacheSize: await provider.imageCacheSize,
			musicCacheSize: await provider.musicCacheSize,
		);
	}

	void set(SettingsChangedType type, dynamic value) =>
			SettingsProvider().setSetting(type, value);

	Stream<bool> get changed => SettingsProvider().isOfflineChanged.stream;
}

class RepoSettingsContainer {
	final int prefetch;
	final bool isOffline;
	final int imageCacheSize;
	final int musicCacheSize;

	RepoSettingsContainer(
			{this.prefetch, this.isOffline, this.imageCacheSize, this.musicCacheSize});
}