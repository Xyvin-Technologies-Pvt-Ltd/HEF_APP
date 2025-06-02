// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$newsApiServiceHash() => r'6af2d8c3ffb7f6c0ba68e946a220423aacd3ae97';

/// See also [newsApiService].
@ProviderFor(newsApiService)
final newsApiServiceProvider = AutoDisposeProvider<NewsApiService>.internal(
  newsApiService,
  name: r'newsApiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$newsApiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NewsApiServiceRef = AutoDisposeProviderRef<NewsApiService>;
String _$fetchNewsHash() => r'1b3a370b8218e58ac375425ffe4369dd54f3d6e4';

/// See also [fetchNews].
@ProviderFor(fetchNews)
final fetchNewsProvider = AutoDisposeFutureProvider<List<News>>.internal(
  fetchNews,
  name: r'fetchNewsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fetchNewsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchNewsRef = AutoDisposeFutureProviderRef<List<News>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
