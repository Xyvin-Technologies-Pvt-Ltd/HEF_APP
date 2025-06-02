// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchUserDetailsHash() => r'e8c15692ae86a3d890061fa9d6282c9ac4f58195';

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
    String id,
  ) {
    return FetchUserDetailsProvider(
      id,
    );
  }

  @override
  FetchUserDetailsProvider getProviderOverride(
    covariant FetchUserDetailsProvider provider,
  ) {
    return call(
      provider.id,
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
    String id,
  ) : this._internal(
          (ref) => fetchUserDetails(
            ref as FetchUserDetailsRef,
            id,
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
          id: id,
        );

  FetchUserDetailsProvider._internal(
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
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<UserModel> createElement() {
    return _FetchUserDetailsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchUserDetailsProvider && other.id == id;
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
mixin FetchUserDetailsRef on AutoDisposeFutureProviderRef<UserModel> {
  /// The parameter `id` of this provider.
  String get id;
}

class _FetchUserDetailsProviderElement
    extends AutoDisposeFutureProviderElement<UserModel>
    with FetchUserDetailsRef {
  _FetchUserDetailsProviderElement(super.provider);

  @override
  String get id => (origin as FetchUserDetailsProvider).id;
}

String _$getMultipleUsersHash() => r'567ebb5195cfe913dcdca7a82df34cc55255c8f5';

/// See also [getMultipleUsers].
@ProviderFor(getMultipleUsers)
const getMultipleUsersProvider = GetMultipleUsersFamily();

/// See also [getMultipleUsers].
class GetMultipleUsersFamily extends Family<AsyncValue<List<UserModel>>> {
  /// See also [getMultipleUsers].
  const GetMultipleUsersFamily();

  /// See also [getMultipleUsers].
  GetMultipleUsersProvider call(
    List<String> userIds,
  ) {
    return GetMultipleUsersProvider(
      userIds,
    );
  }

  @override
  GetMultipleUsersProvider getProviderOverride(
    covariant GetMultipleUsersProvider provider,
  ) {
    return call(
      provider.userIds,
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
  String? get name => r'getMultipleUsersProvider';
}

/// See also [getMultipleUsers].
class GetMultipleUsersProvider
    extends AutoDisposeFutureProvider<List<UserModel>> {
  /// See also [getMultipleUsers].
  GetMultipleUsersProvider(
    List<String> userIds,
  ) : this._internal(
          (ref) => getMultipleUsers(
            ref as GetMultipleUsersRef,
            userIds,
          ),
          from: getMultipleUsersProvider,
          name: r'getMultipleUsersProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getMultipleUsersHash,
          dependencies: GetMultipleUsersFamily._dependencies,
          allTransitiveDependencies:
              GetMultipleUsersFamily._allTransitiveDependencies,
          userIds: userIds,
        );

  GetMultipleUsersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.userIds,
  }) : super.internal();

  final List<String> userIds;

  @override
  Override overrideWith(
    FutureOr<List<UserModel>> Function(GetMultipleUsersRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetMultipleUsersProvider._internal(
        (ref) => create(ref as GetMultipleUsersRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        userIds: userIds,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<UserModel>> createElement() {
    return _GetMultipleUsersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetMultipleUsersProvider && other.userIds == userIds;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, userIds.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GetMultipleUsersRef on AutoDisposeFutureProviderRef<List<UserModel>> {
  /// The parameter `userIds` of this provider.
  List<String> get userIds;
}

class _GetMultipleUsersProviderElement
    extends AutoDisposeFutureProviderElement<List<UserModel>>
    with GetMultipleUsersRef {
  _GetMultipleUsersProviderElement(super.provider);

  @override
  List<String> get userIds => (origin as GetMultipleUsersProvider).userIds;
}

String _$getUserDashboardHash() => r'c2fb8c0fe6a6fa3fc2e403d55ecc45fec2eaaba4';

/// See also [getUserDashboard].
@ProviderFor(getUserDashboard)
const getUserDashboardProvider = GetUserDashboardFamily();

/// See also [getUserDashboard].
class GetUserDashboardFamily extends Family<AsyncValue<UserDashboard>> {
  /// See also [getUserDashboard].
  const GetUserDashboardFamily();

  /// See also [getUserDashboard].
  GetUserDashboardProvider call({
    String? startDate,
    String? endDate,
  }) {
    return GetUserDashboardProvider(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  GetUserDashboardProvider getProviderOverride(
    covariant GetUserDashboardProvider provider,
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
  String? get name => r'getUserDashboardProvider';
}

/// See also [getUserDashboard].
class GetUserDashboardProvider
    extends AutoDisposeFutureProvider<UserDashboard> {
  /// See also [getUserDashboard].
  GetUserDashboardProvider({
    String? startDate,
    String? endDate,
  }) : this._internal(
          (ref) => getUserDashboard(
            ref as GetUserDashboardRef,
            startDate: startDate,
            endDate: endDate,
          ),
          from: getUserDashboardProvider,
          name: r'getUserDashboardProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$getUserDashboardHash,
          dependencies: GetUserDashboardFamily._dependencies,
          allTransitiveDependencies:
              GetUserDashboardFamily._allTransitiveDependencies,
          startDate: startDate,
          endDate: endDate,
        );

  GetUserDashboardProvider._internal(
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
    FutureOr<UserDashboard> Function(GetUserDashboardRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GetUserDashboardProvider._internal(
        (ref) => create(ref as GetUserDashboardRef),
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
    return _GetUserDashboardProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GetUserDashboardProvider &&
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
mixin GetUserDashboardRef on AutoDisposeFutureProviderRef<UserDashboard> {
  /// The parameter `startDate` of this provider.
  String? get startDate;

  /// The parameter `endDate` of this provider.
  String? get endDate;
}

class _GetUserDashboardProviderElement
    extends AutoDisposeFutureProviderElement<UserDashboard>
    with GetUserDashboardRef {
  _GetUserDashboardProviderElement(super.provider);

  @override
  String? get startDate => (origin as GetUserDashboardProvider).startDate;
  @override
  String? get endDate => (origin as GetUserDashboardProvider).endDate;
}

String _$getPaymentYearsHash() => r'0d440c4d5d9e9910e715674fe4c2390cf94d2404';

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
String _$getUserSubscriptionHash() =>
    r'e8001bdc2ebca2c6febc1764b84d991de1fc151c';

/// See also [getUserSubscription].
@ProviderFor(getUserSubscription)
final getUserSubscriptionProvider =
    AutoDisposeFutureProvider<List<Subscription>>.internal(
  getUserSubscription,
  name: r'getUserSubscriptionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$getUserSubscriptionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GetUserSubscriptionRef
    = AutoDisposeFutureProviderRef<List<Subscription>>;
String _$searchBusinessTagsHash() =>
    r'9b4bdf90162c8d87456436c9f64310165656c21d';

/// See also [searchBusinessTags].
@ProviderFor(searchBusinessTags)
const searchBusinessTagsProvider = SearchBusinessTagsFamily();

/// See also [searchBusinessTags].
class SearchBusinessTagsFamily extends Family<AsyncValue<List<String>>> {
  /// See also [searchBusinessTags].
  const SearchBusinessTagsFamily();

  /// See also [searchBusinessTags].
  SearchBusinessTagsProvider call({
    String? search,
  }) {
    return SearchBusinessTagsProvider(
      search: search,
    );
  }

  @override
  SearchBusinessTagsProvider getProviderOverride(
    covariant SearchBusinessTagsProvider provider,
  ) {
    return call(
      search: provider.search,
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
  String? get name => r'searchBusinessTagsProvider';
}

/// See also [searchBusinessTags].
class SearchBusinessTagsProvider
    extends AutoDisposeFutureProvider<List<String>> {
  /// See also [searchBusinessTags].
  SearchBusinessTagsProvider({
    String? search,
  }) : this._internal(
          (ref) => searchBusinessTags(
            ref as SearchBusinessTagsRef,
            search: search,
          ),
          from: searchBusinessTagsProvider,
          name: r'searchBusinessTagsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$searchBusinessTagsHash,
          dependencies: SearchBusinessTagsFamily._dependencies,
          allTransitiveDependencies:
              SearchBusinessTagsFamily._allTransitiveDependencies,
          search: search,
        );

  SearchBusinessTagsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.search,
  }) : super.internal();

  final String? search;

  @override
  Override overrideWith(
    FutureOr<List<String>> Function(SearchBusinessTagsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SearchBusinessTagsProvider._internal(
        (ref) => create(ref as SearchBusinessTagsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        search: search,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<String>> createElement() {
    return _SearchBusinessTagsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SearchBusinessTagsProvider && other.search == search;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, search.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SearchBusinessTagsRef on AutoDisposeFutureProviderRef<List<String>> {
  /// The parameter `search` of this provider.
  String? get search;
}

class _SearchBusinessTagsProviderElement
    extends AutoDisposeFutureProviderElement<List<String>>
    with SearchBusinessTagsRef {
  _SearchBusinessTagsProviderElement(super.provider);

  @override
  String? get search => (origin as SearchBusinessTagsProvider).search;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
