// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchBusinessHash() => r'3c5d70fbec1068790b15e692ae2bac6362252698';

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

/// See also [fetchBusiness].
@ProviderFor(fetchBusiness)
const fetchBusinessProvider = FetchBusinessFamily();

/// See also [fetchBusiness].
class FetchBusinessFamily extends Family<AsyncValue<List<Business>>> {
  /// See also [fetchBusiness].
  const FetchBusinessFamily();

  /// See also [fetchBusiness].
  FetchBusinessProvider call({
    int pageNo = 1,
    int limit = 10,
  }) {
    return FetchBusinessProvider(
      pageNo: pageNo,
      limit: limit,
    );
  }

  @override
  FetchBusinessProvider getProviderOverride(
    covariant FetchBusinessProvider provider,
  ) {
    return call(
      pageNo: provider.pageNo,
      limit: provider.limit,
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
  String? get name => r'fetchBusinessProvider';
}

/// See also [fetchBusiness].
class FetchBusinessProvider extends AutoDisposeFutureProvider<List<Business>> {
  /// See also [fetchBusiness].
  FetchBusinessProvider({
    int pageNo = 1,
    int limit = 10,
  }) : this._internal(
          (ref) => fetchBusiness(
            ref as FetchBusinessRef,
            pageNo: pageNo,
            limit: limit,
          ),
          from: fetchBusinessProvider,
          name: r'fetchBusinessProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchBusinessHash,
          dependencies: FetchBusinessFamily._dependencies,
          allTransitiveDependencies:
              FetchBusinessFamily._allTransitiveDependencies,
          pageNo: pageNo,
          limit: limit,
        );

  FetchBusinessProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.pageNo,
    required this.limit,
  }) : super.internal();

  final int pageNo;
  final int limit;

  @override
  Override overrideWith(
    FutureOr<List<Business>> Function(FetchBusinessRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchBusinessProvider._internal(
        (ref) => create(ref as FetchBusinessRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        pageNo: pageNo,
        limit: limit,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<Business>> createElement() {
    return _FetchBusinessProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchBusinessProvider &&
        other.pageNo == pageNo &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, pageNo.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchBusinessRef on AutoDisposeFutureProviderRef<List<Business>> {
  /// The parameter `pageNo` of this provider.
  int get pageNo;

  /// The parameter `limit` of this provider.
  int get limit;
}

class _FetchBusinessProviderElement
    extends AutoDisposeFutureProviderElement<List<Business>>
    with FetchBusinessRef {
  _FetchBusinessProviderElement(super.provider);

  @override
  int get pageNo => (origin as FetchBusinessProvider).pageNo;
  @override
  int get limit => (origin as FetchBusinessProvider).limit;
}

String _$fetchMyBusinessesHash() => r'cd28a01b77246696da5e0db33eabc27135b80876';

/// See also [fetchMyBusinesses].
@ProviderFor(fetchMyBusinesses)
final fetchMyBusinessesProvider =
    AutoDisposeFutureProvider<List<Business>>.internal(
  fetchMyBusinesses,
  name: r'fetchMyBusinessesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchMyBusinessesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchMyBusinessesRef = AutoDisposeFutureProviderRef<List<Business>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
