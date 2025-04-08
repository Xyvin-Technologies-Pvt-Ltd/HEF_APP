// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$groupApiServiceHash() => r'd28d349419c771385eade1f4df7641b2abb83453';

/// See also [groupApiService].
@ProviderFor(groupApiService)
final groupApiServiceProvider = AutoDisposeProvider<GroupApiService>.internal(
  groupApiService,
  name: r'groupApiServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$groupApiServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GroupApiServiceRef = AutoDisposeProviderRef<GroupApiService>;
String _$getGroupListHash() => r'f1dedff7fb8f2056b2d3e370dd749c5a17fd0c52';

/// See also [getGroupList].
@ProviderFor(getGroupList)
final getGroupListProvider =
    AutoDisposeFutureProvider<List<GroupModel>>.internal(
  getGroupList,
  name: r'getGroupListProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getGroupListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetGroupListRef = AutoDisposeFutureProviderRef<List<GroupModel>>;
String _$fetchGroupInfoHash() => r'4ed721281a813e285aeca62bea134d0bf42ebdf5';

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

/// See also [fetchGroupInfo].
@ProviderFor(fetchGroupInfo)
const fetchGroupInfoProvider = FetchGroupInfoFamily();

/// See also [fetchGroupInfo].
class FetchGroupInfoFamily extends Family<AsyncValue<GroupInfoModel>> {
  /// See also [fetchGroupInfo].
  const FetchGroupInfoFamily();

  /// See also [fetchGroupInfo].
  FetchGroupInfoProvider call({
    required String id,
  }) {
    return FetchGroupInfoProvider(
      id: id,
    );
  }

  @override
  FetchGroupInfoProvider getProviderOverride(
    covariant FetchGroupInfoProvider provider,
  ) {
    return call(
      id: provider.id,
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
  String? get name => r'fetchGroupInfoProvider';
}

/// See also [fetchGroupInfo].
class FetchGroupInfoProvider extends AutoDisposeFutureProvider<GroupInfoModel> {
  /// See also [fetchGroupInfo].
  FetchGroupInfoProvider({
    required String id,
  }) : this._internal(
          (ref) => fetchGroupInfo(
            ref as FetchGroupInfoRef,
            id: id,
          ),
          from: fetchGroupInfoProvider,
          name: r'fetchGroupInfoProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchGroupInfoHash,
          dependencies: FetchGroupInfoFamily._dependencies,
          allTransitiveDependencies:
              FetchGroupInfoFamily._allTransitiveDependencies,
          id: id,
        );

  FetchGroupInfoProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final String id;

  @override
  Override overrideWith(
    FutureOr<GroupInfoModel> Function(FetchGroupInfoRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchGroupInfoProvider._internal(
        (ref) => create(ref as FetchGroupInfoRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<GroupInfoModel> createElement() {
    return _FetchGroupInfoProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchGroupInfoProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchGroupInfoRef on AutoDisposeFutureProviderRef<GroupInfoModel> {
  /// The parameter `id` of this provider.
  String get id;
}

class _FetchGroupInfoProviderElement
    extends AutoDisposeFutureProviderElement<GroupInfoModel>
    with FetchGroupInfoRef {
  _FetchGroupInfoProviderElement(super.provider);

  @override
  String get id => (origin as FetchGroupInfoProvider).id;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
