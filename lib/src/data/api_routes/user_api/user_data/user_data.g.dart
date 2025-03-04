// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchUserDetailsHash() => r'f831a10ec4680e1c639dd42339f4b30164f80484';

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

/// See also [fetchUserDetails].
@ProviderFor(fetchUserDetails)
const fetchUserDetailsProvider = FetchUserDetailsFamily();

/// See also [fetchUserDetails].
class FetchUserDetailsFamily extends Family<AsyncValue<UserModel>> {
  /// See also [fetchUserDetails].
  const FetchUserDetailsFamily();

  /// See also [fetchUserDetails].
  FetchUserDetailsProvider call(
    String userId,
  ) {
    return FetchUserDetailsProvider(
      userId,
    );
  }

  @override
  FetchUserDetailsProvider getProviderOverride(
    covariant FetchUserDetailsProvider provider,
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
  String? get name => r'fetchUserDetailsProvider';
}

/// See also [fetchUserDetails].
class FetchUserDetailsProvider extends AutoDisposeFutureProvider<UserModel> {
  /// See also [fetchUserDetails].
  FetchUserDetailsProvider(
    String userId,
  ) : this._internal(
          (ref) => fetchUserDetails(
            ref as FetchUserDetailsRef,
            userId,
          ),
          from: fetchUserDetailsProvider,
          name: r'fetchUserDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchUserDetailsHash,
          dependencies: FetchUserDetailsFamily._dependencies,
          allTransitiveDependencies:
              FetchUserDetailsFamily._allTransitiveDependencies,
          userId: userId,
        );

  FetchUserDetailsProvider._internal(
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
    FutureOr<UserModel> Function(FetchUserDetailsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchUserDetailsProvider._internal(
        (ref) => create(ref as FetchUserDetailsRef),
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
  AutoDisposeFutureProviderElement<UserModel> createElement() {
    return _FetchUserDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchUserDetailsProvider && other.userId == userId;
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
mixin FetchUserDetailsRef on AutoDisposeFutureProviderRef<UserModel> {
  /// The parameter `userId` of this provider.
  String get userId;
}

class _FetchUserDetailsProviderElement
    extends AutoDisposeFutureProviderElement<UserModel>
    with FetchUserDetailsRef {
  _FetchUserDetailsProviderElement(super.provider);

  @override
  String get userId => (origin as FetchUserDetailsProvider).userId;
}

String _$fetchUserDashboardDetailsHash() =>
    r'955b0540ffa80d5417f0baa496213692d43c8692';

/// See also [fetchUserDashboardDetails].
@ProviderFor(fetchUserDashboardDetails)
const fetchUserDashboardDetailsProvider = FetchUserDashboardDetailsFamily();

/// See also [fetchUserDashboardDetails].
class FetchUserDashboardDetailsFamily
    extends Family<AsyncValue<UserDashboard>> {
  /// See also [fetchUserDashboardDetails].
  const FetchUserDashboardDetailsFamily();

  /// See also [fetchUserDashboardDetails].
  FetchUserDashboardDetailsProvider call({
    String? startDate,
    String? endDate,
  }) {
    return FetchUserDashboardDetailsProvider(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  FetchUserDashboardDetailsProvider getProviderOverride(
    covariant FetchUserDashboardDetailsProvider provider,
  ) {
    return call(
      startDate: provider.startDate,
      endDate: provider.endDate,
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
  String? get name => r'fetchUserDashboardDetailsProvider';
}

/// See also [fetchUserDashboardDetails].
class FetchUserDashboardDetailsProvider
    extends AutoDisposeFutureProvider<UserDashboard> {
  /// See also [fetchUserDashboardDetails].
  FetchUserDashboardDetailsProvider({
    String? startDate,
    String? endDate,
  }) : this._internal(
          (ref) => fetchUserDashboardDetails(
            ref as FetchUserDashboardDetailsRef,
            startDate: startDate,
            endDate: endDate,
          ),
          from: fetchUserDashboardDetailsProvider,
          name: r'fetchUserDashboardDetailsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchUserDashboardDetailsHash,
          dependencies: FetchUserDashboardDetailsFamily._dependencies,
          allTransitiveDependencies:
              FetchUserDashboardDetailsFamily._allTransitiveDependencies,
          startDate: startDate,
          endDate: endDate,
        );

  FetchUserDashboardDetailsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.startDate,
    required this.endDate,
  }) : super.internal();

  final String? startDate;
  final String? endDate;

  @override
  Override overrideWith(
    FutureOr<UserDashboard> Function(FetchUserDashboardDetailsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchUserDashboardDetailsProvider._internal(
        (ref) => create(ref as FetchUserDashboardDetailsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserDashboard> createElement() {
    return _FetchUserDashboardDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchUserDashboardDetailsProvider &&
        other.startDate == startDate &&
        other.endDate == endDate;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, startDate.hashCode);
    hash = _SystemHash.combine(hash, endDate.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchUserDashboardDetailsRef
    on AutoDisposeFutureProviderRef<UserDashboard> {
  /// The parameter `startDate` of this provider.
  String? get startDate;

  /// The parameter `endDate` of this provider.
  String? get endDate;
}

class _FetchUserDashboardDetailsProviderElement
    extends AutoDisposeFutureProviderElement<UserDashboard>
    with FetchUserDashboardDetailsRef {
  _FetchUserDashboardDetailsProviderElement(super.provider);

  @override
  String? get startDate =>
      (origin as FetchUserDashboardDetailsProvider).startDate;
  @override
  String? get endDate => (origin as FetchUserDashboardDetailsProvider).endDate;
}

String _$getSubscriptionHash() => r'b2ae269a755d077ac256f7f9c2237f6c3a39dd83';

/// See also [getSubscription].
@ProviderFor(getSubscription)
final getSubscriptionProvider =
    AutoDisposeFutureProvider<List<Subscription>>.internal(
  getSubscription,
  name: r'getSubscriptionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getSubscriptionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetSubscriptionRef = AutoDisposeFutureProviderRef<List<Subscription>>;
String _$getPaymentYearsHash() => r'7e4cc9f8f5f6d7ef38c31fd7976a18125e9c6112';

/// See also [getPaymentYears].
@ProviderFor(getPaymentYears)
final getPaymentYearsProvider =
    AutoDisposeFutureProvider<List<PaymentYearModel>>.internal(
  getPaymentYears,
  name: r'getPaymentYearsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getPaymentYearsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetPaymentYearsRef
    = AutoDisposeFutureProviderRef<List<PaymentYearModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
