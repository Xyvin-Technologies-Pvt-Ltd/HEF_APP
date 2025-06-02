// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_details.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchChapterDetailsHash() =>
    r'3088ad1cbb27936c34c67454ed1c152a3009ac96';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [fetchChapterDetails].
@ProviderFor(fetchChapterDetails)
const fetchChapterDetailsProvider = FetchChapterDetailsFamily();

/// See also [fetchChapterDetails].
class FetchChapterDetailsFamily
    extends Family<AsyncValue<ChapterDetailsModel>> {
  /// See also [fetchChapterDetails].
  const FetchChapterDetailsFamily();

  /// See also [fetchChapterDetails].
  FetchChapterDetailsProvider call(
    String chapterId,
  ) {
    return FetchChapterDetailsProvider(
      chapterId,
    );
  }

  @override
  FetchChapterDetailsProvider getProviderOverride(
    covariant FetchChapterDetailsProvider provider,
  ) {
    return call(
      provider.chapterId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'fetchChapterDetailsProvider';
}

/// See also [fetchChapterDetails].
class FetchChapterDetailsProvider
    extends AutoDisposeFutureProvider<ChapterDetailsModel> {
  /// See also [fetchChapterDetails].
  FetchChapterDetailsProvider(
    String chapterId,
  ) : this._internal(
          (ref) => fetchChapterDetails(
            ref as FetchChapterDetailsRef,
            chapterId,
          ),
          from: fetchChapterDetailsProvider,
          name: r'fetchChapterDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchChapterDetailsHash,
          dependencies: FetchChapterDetailsFamily._dependencies,
          allTransitiveDependencies:
              FetchChapterDetailsFamily._allTransitiveDependencies,
          chapterId: chapterId,
        );

  FetchChapterDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chapterId,
  }) : super.internal();

  final String chapterId;

  @override
  Override overrideWith(
    FutureOr<ChapterDetailsModel> Function(FetchChapterDetailsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchChapterDetailsProvider._internal(
        (ref) => create(ref as FetchChapterDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chapterId: chapterId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChapterDetailsModel> createElement() {
    return _FetchChapterDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchChapterDetailsProvider && other.chapterId == chapterId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chapterId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchChapterDetailsRef
    on AutoDisposeFutureProviderRef<ChapterDetailsModel> {
  /// The parameter `chapterId` of this provider.
  String get chapterId;
}

class _FetchChapterDetailsProviderElement
    extends AutoDisposeFutureProviderElement<ChapterDetailsModel>
    with FetchChapterDetailsRef {
  _FetchChapterDetailsProviderElement(super.provider);

  @override
  String get chapterId => (origin as FetchChapterDetailsProvider).chapterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
