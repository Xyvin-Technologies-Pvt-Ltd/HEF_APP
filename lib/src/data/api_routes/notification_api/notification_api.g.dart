// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_api.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fetchNotificationsHash() =>
    r'46a63fcd38d5c752ee38842d15fa68c8f656c0a4';

/// See also [fetchNotifications].
@ProviderFor(fetchNotifications)
final fetchNotificationsProvider =
    AutoDisposeFutureProvider<List<NotificationModel>>.internal(
  fetchNotifications,
  name: r'fetchNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fetchNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FetchNotificationsRef
    = AutoDisposeFutureProviderRef<List<NotificationModel>>;
String _$clearNotificationHash() => r'49160175bff76cc7ca5d9efe4d7990157bb403b8';

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

/// See also [clearNotification].
@ProviderFor(clearNotification)
const clearNotificationProvider = ClearNotificationFamily();

/// See also [clearNotification].
class ClearNotificationFamily extends Family<AsyncValue<void>> {
  /// See also [clearNotification].
  const ClearNotificationFamily();

  /// See also [clearNotification].
  ClearNotificationProvider call(
    String notificationId,
  ) {
    return ClearNotificationProvider(
      notificationId,
    );
  }

  @override
  ClearNotificationProvider getProviderOverride(
    covariant ClearNotificationProvider provider,
  ) {
    return call(
      provider.notificationId,
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
  String? get name => r'clearNotificationProvider';
}

/// See also [clearNotification].
class ClearNotificationProvider extends AutoDisposeFutureProvider<void> {
  /// See also [clearNotification].
  ClearNotificationProvider(
    String notificationId,
  ) : this._internal(
          (ref) => clearNotification(
            ref as ClearNotificationRef,
            notificationId,
          ),
          from: clearNotificationProvider,
          name: r'clearNotificationProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$clearNotificationHash,
          dependencies: ClearNotificationFamily._dependencies,
          allTransitiveDependencies:
              ClearNotificationFamily._allTransitiveDependencies,
          notificationId: notificationId,
        );

  ClearNotificationProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.notificationId,
  }) : super.internal();

  final String notificationId;

  @override
  Override overrideWith(
    FutureOr<void> Function(ClearNotificationRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ClearNotificationProvider._internal(
        (ref) => create(ref as ClearNotificationRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        notificationId: notificationId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<void> createElement() {
    return _ClearNotificationProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClearNotificationProvider &&
        other.notificationId == notificationId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, notificationId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ClearNotificationRef on AutoDisposeFutureProviderRef<void> {
  /// The parameter `notificationId` of this provider.
  String get notificationId;
}

class _ClearNotificationProviderElement
    extends AutoDisposeFutureProviderElement<void> with ClearNotificationRef {
  _ClearNotificationProviderElement(super.provider);

  @override
  String get notificationId =>
      (origin as ClearNotificationProvider).notificationId;
}

String _$clearAllNotificationsHash() =>
    r'5d6035a3897619916a9fe85db2e7308850e11f22';

/// See also [clearAllNotifications].
@ProviderFor(clearAllNotifications)
final clearAllNotificationsProvider = AutoDisposeFutureProvider<void>.internal(
  clearAllNotifications,
  name: r'clearAllNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$clearAllNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClearAllNotificationsRef = AutoDisposeFutureProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
