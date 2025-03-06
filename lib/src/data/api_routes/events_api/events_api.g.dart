// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchEventsHash() => r'4b74f158cc159f5a80484f4a64f730f0a697c640';

/// See also [fetchEvents].
@ProviderFor(fetchEvents)
final fetchEventsProvider = AutoDisposeFutureProvider<List<Event>>.internal(
  fetchEvents,
  name: r'fetchEventsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$fetchEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchEventsRef = AutoDisposeFutureProviderRef<List<Event>>;
String _$fetchEventAttendanceHash() =>
    r'c3d8d19f68fc8dc9fb804faa874624e88b3c2f0d';

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

/// See also [fetchEventAttendance].
@ProviderFor(fetchEventAttendance)
const fetchEventAttendanceProvider = FetchEventAttendanceFamily();

/// See also [fetchEventAttendance].
class FetchEventAttendanceFamily
    extends Family<AsyncValue<AttendanceUserListModel>> {
  /// See also [fetchEventAttendance].
  const FetchEventAttendanceFamily();

  /// See also [fetchEventAttendance].
  FetchEventAttendanceProvider call({
    required String eventId,
  }) {
    return FetchEventAttendanceProvider(
      eventId: eventId,
    );
  }

  @override
  FetchEventAttendanceProvider getProviderOverride(
    covariant FetchEventAttendanceProvider provider,
  ) {
    return call(
      eventId: provider.eventId,
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
  String? get name => r'fetchEventAttendanceProvider';
}

/// See also [fetchEventAttendance].
class FetchEventAttendanceProvider
    extends AutoDisposeFutureProvider<AttendanceUserListModel> {
  /// See also [fetchEventAttendance].
  FetchEventAttendanceProvider({
    required String eventId,
  }) : this._internal(
          (ref) => fetchEventAttendance(
            ref as FetchEventAttendanceRef,
            eventId: eventId,
          ),
          from: fetchEventAttendanceProvider,
          name: r'fetchEventAttendanceProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$fetchEventAttendanceHash,
          dependencies: FetchEventAttendanceFamily._dependencies,
          allTransitiveDependencies:
              FetchEventAttendanceFamily._allTransitiveDependencies,
          eventId: eventId,
        );

  FetchEventAttendanceProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.eventId,
  }) : super.internal();

  final String eventId;

  @override
  Override overrideWith(
    FutureOr<AttendanceUserListModel> Function(FetchEventAttendanceRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FetchEventAttendanceProvider._internal(
        (ref) => create(ref as FetchEventAttendanceRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        eventId: eventId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AttendanceUserListModel> createElement() {
    return _FetchEventAttendanceProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchEventAttendanceProvider && other.eventId == eventId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, eventId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FetchEventAttendanceRef
    on AutoDisposeFutureProviderRef<AttendanceUserListModel> {
  /// The parameter `eventId` of this provider.
  String get eventId;
}

class _FetchEventAttendanceProviderElement
    extends AutoDisposeFutureProviderElement<AttendanceUserListModel>
    with FetchEventAttendanceRef {
  _FetchEventAttendanceProviderElement(super.provider);

  @override
  String get eventId => (origin as FetchEventAttendanceProvider).eventId;
}

String _$fetchMyEventsHash() => r'61d68719db492c84b95f14764f17582fac8d372b';

/// See also [fetchMyEvents].
@ProviderFor(fetchMyEvents)
final fetchMyEventsProvider = AutoDisposeFutureProvider<List<Event>>.internal(
  fetchMyEvents,
  name: r'fetchMyEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchMyEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchMyEventsRef = AutoDisposeFutureProviderRef<List<Event>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
