// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchActivityHash() => r'6390f9f17254c34760514b06564940c0863fa167';

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

/// See also [fetchActivity].
@ProviderFor(fetchActivity)
const fetchActivityProvider = FetchActivityFamily();

/// See also [fetchActivity].
class FetchActivityFamily extends Family<AsyncValue<List<ActivityModel>>> {
  /// See also [fetchActivity].
  const FetchActivityFamily();

  /// See also [fetchActivity].
  FetchActivityProvider call({
    required String? chapterId,
  }) {
    return FetchActivityProvider(
      chapterId: chapterId,
    );
  }

  @override
  FetchActivityProvider getProviderOverride(
    covariant FetchActivityProvider provider,
  ) {
    return call(
      chapterId: provider.chapterId,
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
  String? get name => r'fetchActivityProvider';
}

/// See also [fetchActivity].
class FetchActivityProvider
    extends AutoDisposeFutureProvider<List<ActivityModel>> {
  /// See also [fetchActivity].
  FetchActivityProvider({
    required String? chapterId,
  }) : this._internal(
          (ref) => fetchActivity(
            ref as FetchActivityRef,
            chapterId: chapterId,
          ),
          from: fetchActivityProvider,
          name: r'fetchActivityProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchActivityHash,
          dependencies: FetchActivityFamily._dependencies,
          allTransitiveDependencies:
              FetchActivityFamily._allTransitiveDependencies,
          chapterId: chapterId,
        );

  FetchActivityProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chapterId,
  }) : super.internal();

  final String? chapterId;

  @override
  Override overrideWith(
    FutureOr<List<ActivityModel>> Function(FetchActivityRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchActivityProvider._internal(
        (ref) => create(ref as FetchActivityRef),
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
  AutoDisposeFutureProviderElement<List<ActivityModel>> createElement() {
    return _FetchActivityProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchActivityProvider && other.chapterId == chapterId;
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
mixin FetchActivityRef on AutoDisposeFutureProviderRef<List<ActivityModel>> {
  /// The parameter `chapterId` of this provider.
  String? get chapterId;
}

class _FetchActivityProviderElement
    extends AutoDisposeFutureProviderElement<List<ActivityModel>>
    with FetchActivityRef {
  _FetchActivityProviderElement(super.provider);

  @override
  String? get chapterId => (origin as FetchActivityProvider).chapterId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
