// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_details.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchChapterDetailsHash() =>
    r'd3f80a0b07f8d41dffb0cd72e7c9f7ae8c249c3e';

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
    String userId,
  ) {
    return FetchChapterDetailsProvider(
      userId,
    );
  }

  @override
  FetchChapterDetailsProvider getProviderOverride(
    covariant FetchChapterDetailsProvider provider,
  ) {
    return call(
      provider.userId,
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
    String userId,
  ) : this._internal(
          (ref) => fetchChapterDetails(
            ref as FetchChapterDetailsRef,
            userId,
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
          userId: userId,
        );

  FetchChapterDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userId,
  }) : super.internal();

  final String userId;

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
        userId: userId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ChapterDetailsModel> createElement() {
    return _FetchChapterDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchChapterDetailsProvider && other.userId == userId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchChapterDetailsRef
    on AutoDisposeFutureProviderRef<ChapterDetailsModel> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _FetchChapterDetailsProviderElement
    extends AutoDisposeFutureProviderElement<ChapterDetailsModel>
    with FetchChapterDetailsRef {
  _FetchChapterDetailsProviderElement(super.provider);

  @override
  String get userId => (origin as FetchChapterDetailsProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
