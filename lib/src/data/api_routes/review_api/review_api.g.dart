// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchReviewsHash() => r'b6b5ecac223bb9727da359cc6a4967bb9fb4f12e';

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

/// See also [fetchReviews].
@ProviderFor(fetchReviews)
const fetchReviewsProvider = FetchReviewsFamily();

/// See also [fetchReviews].
class FetchReviewsFamily extends Family<AsyncValue<List<ReviewModel>>> {
  /// See also [fetchReviews].
  const FetchReviewsFamily();

  /// See also [fetchReviews].
  FetchReviewsProvider call({
    required String userId,
  }) {
    return FetchReviewsProvider(
      userId: userId,
    );
  }

  @override
  FetchReviewsProvider getProviderOverride(
    covariant FetchReviewsProvider provider,
  ) {
    return call(
      userId: provider.userId,
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
  String? get name => r'fetchReviewsProvider';
}

/// See also [fetchReviews].
class FetchReviewsProvider
    extends AutoDisposeFutureProvider<List<ReviewModel>> {
  /// See also [fetchReviews].
  FetchReviewsProvider({
    required String userId,
  }) : this._internal(
          (ref) => fetchReviews(
            ref as FetchReviewsRef,
            userId: userId,
          ),
          from: fetchReviewsProvider,
          name: r'fetchReviewsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchReviewsHash,
          dependencies: FetchReviewsFamily._dependencies,
          allTransitiveDependencies:
              FetchReviewsFamily._allTransitiveDependencies,
          userId: userId,
        );

  FetchReviewsProvider._internal(
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
    FutureOr<List<ReviewModel>> Function(FetchReviewsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchReviewsProvider._internal(
        (ref) => create(ref as FetchReviewsRef),
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
  AutoDisposeFutureProviderElement<List<ReviewModel>> createElement() {
    return _FetchReviewsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchReviewsProvider && other.userId == userId;
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
mixin FetchReviewsRef on AutoDisposeFutureProviderRef<List<ReviewModel>> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _FetchReviewsProviderElement
    extends AutoDisposeFutureProviderElement<List<ReviewModel>>
    with FetchReviewsRef {
  _FetchReviewsProviderElement(super.provider);

  @override
  String get userId => (origin as FetchReviewsProvider).userId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
