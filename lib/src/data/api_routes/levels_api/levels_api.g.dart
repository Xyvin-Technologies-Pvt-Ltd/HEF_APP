// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'levels_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchStatesHash() => r'40daaabdbb8ad91f2aba464dee208be398869688';

/// See also [fetchStates].
@ProviderFor(fetchStates)
final fetchStatesProvider =
    AutoDisposeFutureProvider<List<LevelModel>>.internal(
  fetchStates,
  name: r'fetchStatesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fetchStatesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchStatesRef = AutoDisposeFutureProviderRef<List<LevelModel>>;
String _$fetchLevelDataHash() => r'2c9ac4c7ee5c19790f5dc615420e478732318f07';

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

/// See also [fetchLevelData].
@ProviderFor(fetchLevelData)
const fetchLevelDataProvider = FetchLevelDataFamily();

/// See also [fetchLevelData].
class FetchLevelDataFamily extends Family<AsyncValue<List<LevelModel>>> {
  /// See also [fetchLevelData].
  const FetchLevelDataFamily();

  /// See also [fetchLevelData].
  FetchLevelDataProvider call(
    String id,
    String level,
  ) {
    return FetchLevelDataProvider(
      id,
      level,
    );
  }

  @override
  FetchLevelDataProvider getProviderOverride(
    covariant FetchLevelDataProvider provider,
  ) {
    return call(
      provider.id,
      provider.level,
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
  String? get name => r'fetchLevelDataProvider';
}

/// See also [fetchLevelData].
class FetchLevelDataProvider
    extends AutoDisposeFutureProvider<List<LevelModel>> {
  /// See also [fetchLevelData].
  FetchLevelDataProvider(
    String id,
    String level,
  ) : this._internal(
          (ref) => fetchLevelData(
            ref as FetchLevelDataRef,
            id,
            level,
          ),
          from: fetchLevelDataProvider,
          name: r'fetchLevelDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchLevelDataHash,
          dependencies: FetchLevelDataFamily._dependencies,
          allTransitiveDependencies:
              FetchLevelDataFamily._allTransitiveDependencies,
          id: id,
          level: level,
        );

  FetchLevelDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
    required this.level,
  }) : super.internal();

  final String id;
  final String level;

  @override
  Override overrideWith(
    FutureOr<List<LevelModel>> Function(FetchLevelDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchLevelDataProvider._internal(
        (ref) => create(ref as FetchLevelDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
        level: level,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<LevelModel>> createElement() {
    return _FetchLevelDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchLevelDataProvider &&
        other.id == id &&
        other.level == level;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);
    hash = _SystemHash.combine(hash, level.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchLevelDataRef on AutoDisposeFutureProviderRef<List<LevelModel>> {
  /// The parameter `id` of this provider.
  String get id;

  /// The parameter `level` of this provider.
  String get level;
}

class _FetchLevelDataProviderElement
    extends AutoDisposeFutureProviderElement<List<LevelModel>>
    with FetchLevelDataRef {
  _FetchLevelDataProviderElement(super.provider);

  @override
  String get id => (origin as FetchLevelDataProvider).id;
  @override
  String get level => (origin as FetchLevelDataProvider).level;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
