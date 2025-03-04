// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchAnalyticsHash() => r'6d92f298b8010154584debff5c70e185b0d4550b';

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

/// See also [fetchAnalytics].
@ProviderFor(fetchAnalytics)
const fetchAnalyticsProvider = FetchAnalyticsFamily();

/// See also [fetchAnalytics].
class FetchAnalyticsFamily extends Family<AsyncValue<List<AnalyticsModel>>> {
  /// See also [fetchAnalytics].
  const FetchAnalyticsFamily();

  /// See also [fetchAnalytics].
  FetchAnalyticsProvider call({
    required String? type,
    String? startDate,
    String? endDate,
    String? requestType,
  }) {
    return FetchAnalyticsProvider(
      type: type,
      startDate: startDate,
      endDate: endDate,
      requestType: requestType,
    );
  }

  @override
  FetchAnalyticsProvider getProviderOverride(
    covariant FetchAnalyticsProvider provider,
  ) {
    return call(
      type: provider.type,
      startDate: provider.startDate,
      endDate: provider.endDate,
      requestType: provider.requestType,
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
  String? get name => r'fetchAnalyticsProvider';
}

/// See also [fetchAnalytics].
class FetchAnalyticsProvider
    extends AutoDisposeFutureProvider<List<AnalyticsModel>> {
  /// See also [fetchAnalytics].
  FetchAnalyticsProvider({
    required String? type,
    String? startDate,
    String? endDate,
    String? requestType,
  }) : this._internal(
          (ref) => fetchAnalytics(
            ref as FetchAnalyticsRef,
            type: type,
            startDate: startDate,
            endDate: endDate,
            requestType: requestType,
          ),
          from: fetchAnalyticsProvider,
          name: r'fetchAnalyticsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchAnalyticsHash,
          dependencies: FetchAnalyticsFamily._dependencies,
          allTransitiveDependencies:
              FetchAnalyticsFamily._allTransitiveDependencies,
          type: type,
          startDate: startDate,
          endDate: endDate,
          requestType: requestType,
        );

  FetchAnalyticsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.requestType,
  }) : super.internal();

  final String? type;
  final String? startDate;
  final String? endDate;
  final String? requestType;

  @override
  Override overrideWith(
    FutureOr<List<AnalyticsModel>> Function(FetchAnalyticsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchAnalyticsProvider._internal(
        (ref) => create(ref as FetchAnalyticsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        type: type,
        startDate: startDate,
        endDate: endDate,
        requestType: requestType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<AnalyticsModel>> createElement() {
    return _FetchAnalyticsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchAnalyticsProvider &&
        other.type == type &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.requestType == requestType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, requestType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchAnalyticsRef on AutoDisposeFutureProviderRef<List<AnalyticsModel>> {
  /// The parameter `type` of this provider.
  String? get type;

  /// The parameter `startDate` of this provider.
  String? get startDate;

  /// The parameter `endDate` of this provider.
  String? get endDate;

  /// The parameter `requestType` of this provider.
  String? get requestType;
}

class _FetchAnalyticsProviderElement
    extends AutoDisposeFutureProviderElement<List<AnalyticsModel>>
    with FetchAnalyticsRef {
  _FetchAnalyticsProviderElement(super.provider);

  @override
  String? get type => (origin as FetchAnalyticsProvider).type;
  @override
  String? get startDate => (origin as FetchAnalyticsProvider).startDate;
  @override
  String? get endDate => (origin as FetchAnalyticsProvider).endDate;
  @override
  String? get requestType => (origin as FetchAnalyticsProvider).requestType;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
