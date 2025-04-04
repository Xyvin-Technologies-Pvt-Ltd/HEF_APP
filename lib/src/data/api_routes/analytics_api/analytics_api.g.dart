// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchAnalyticsHash() => r'09b4814c1d4658bdc321cdf80369474be2b68e09';

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
    int? pageNo,
    int? limit,
  }) {
    return FetchAnalyticsProvider(
      type: type,
      startDate: startDate,
      endDate: endDate,
      requestType: requestType,
      pageNo: pageNo,
      limit: limit,
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
    int? pageNo,
    int? limit,
  }) : this._internal(
          (ref) => fetchAnalytics(
            ref as FetchAnalyticsRef,
            type: type,
            startDate: startDate,
            endDate: endDate,
            requestType: requestType,
            pageNo: pageNo,
            limit: limit,
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
          pageNo: pageNo,
          limit: limit,
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
    required this.pageNo,
    required this.limit,
  }) : super.internal();

  final String? type;
  final String? startDate;
  final String? endDate;
  final String? requestType;
  final int? pageNo;
  final int? limit;

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
        pageNo: pageNo,
        limit: limit,
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
        other.requestType == requestType &&
        other.pageNo == pageNo &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, type.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);
    hash = _SystemHash.combine(hash, requestType.hashCode);
    hash = _SystemHash.combine(hash, pageNo.hashCode);
    hash = _SystemHash.combine(hash, limit.hashCode);

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

  /// The parameter `pageNo` of this provider.
  int? get pageNo;

  /// The parameter `limit` of this provider.
  int? get limit;
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
  @override
  int? get pageNo => (origin as FetchAnalyticsProvider).pageNo;
  @override
  int? get limit => (origin as FetchAnalyticsProvider).limit;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
