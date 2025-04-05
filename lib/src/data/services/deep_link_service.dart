import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hef/src/data/api_routes/events_api/events_api.dart';
import 'package:hef/src/data/api_routes/user_api/user_data/user_data.dart';
import 'package:hef/src/data/globals.dart';
import 'package:hef/src/data/models/chat_model.dart';
import 'package:hef/src/data/services/navgitor_service.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  Uri? _pendingDeepLink;

  Uri? get pendingDeepLink => _pendingDeepLink;
  void clearPendingDeepLink() {
    _pendingDeepLink = null;
  }

  // Initialize and handle deep links
  Future<void> initialize(BuildContext context) async {
    try {
      // Handle deep link when app is started from terminated state
      final appLink = await _appLinks.getInitialLink();
      if (appLink != null) {
        _pendingDeepLink = appLink;
      }

      // Handle deep link when app is in background or foreground
      _appLinks.uriLinkStream.listen((uri) {
        _pendingDeepLink = uri;
        handleDeepLink(uri);
      });
    } catch (e) {
      debugPrint('Deep link initialization error: $e');
    }
  }

  Future<void> handleDeepLink(Uri uri) async {
    try {
      final pathSegments = uri.pathSegments;
      if (pathSegments.isEmpty) return;

      // Check if app is in the foreground
      bool isAppForeground =
          NavigationService.navigatorKey.currentState?.overlay != null;

      if (!isAppForeground) {
        // App is in the background or terminated, go through splash & mainpage
        NavigationService.navigatorKey.currentState?.pushNamedAndRemoveUntil(
          'Splash',
          (route) => false,
        );

        await Future.delayed(
            Duration(seconds: 2)); // Simulating splash processing

        NavigationService.navigatorKey.currentState
            ?.pushReplacementNamed('MainPage');

        await Future.delayed(Duration(milliseconds: 500)); // Ensure stability
      }

      // Now navigate to the deep link destination
      switch (pathSegments[0]) {
        case 'chat':
          if (pathSegments.length > 1) {
            final userId = pathSegments[1];
            try {
       
              final user = await UserService. fetchUserDetails(userId);
              NavigationService.navigatorKey.currentState
                  ?.pushNamed('IndividualPage', arguments: {
                'sender': Participant(id: id),
                'receiver': Participant(
                  id: user.uid,
                  name: user.name,
                  image: user.image,
                ),
              });
            } catch (e) {
              debugPrint('Error fetching user: $e');
              _showError('Unable to load profile');
            }
          }
          break;
        case 'event':
          if (pathSegments.length > 1) {
            final eventId = pathSegments[1];
            try {
              final event = await fetchEventById(eventId);
              NavigationService.navigatorKey.currentState
                  ?.pushNamed('ViewMoreEvent', arguments: event);
            } catch (e) {
              debugPrint('Error fetching event: $e');
              _showError('Unable to load profile');
            }
          }
          break;

        case 'my_feeds':
          try {
            NavigationService.navigatorKey.currentState
                ?.pushNamed('MyBusinesses');
          } catch (e) {
            debugPrint('Error fetching requirement: $e');
            _showError('Unable to load profile');
          }

          break;
        case 'my_products':
          try {
            NavigationService.navigatorKey.currentState
                ?.pushNamed('MyProducts');
          } catch (e) {
            debugPrint('Error fetching requirement: $e');
            _showError('Unable to load profile');
          }
        case 'my_subscription':
          try {
            NavigationService.navigatorKey.currentState
                ?.pushNamed('MySubscriptionPage');
          } catch (e) {
            debugPrint('Error fetching requirement: $e');
            _showError('Unable to load profile');
          }

          break;

        case 'mainpage':
          break;

        default:
          NavigationService.navigatorKey.currentState
              ?.pushNamed('NotificationPage');
          break;
      }
    } catch (e) {
      debugPrint('Deep link handling error: $e');
      _showError('Unable to process the notification');
    }
  }

  void _showError(String message) {
    if (NavigationService.navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(NavigationService.navigatorKey.currentContext!)
          .showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  String? getDeepLinkPath(String screen, {String? id}) {
    switch (screen) {
      case 'chat':
        return id != null ? 'hef://app/chat/$id' : 'hef://app/chat';
      case 'event':
        return id != null ? 'hef://app/event/$id' : 'hef://app/event';
      case 'my_subscription':
        return 'hef://app/my_subscription';
      case 'my_products':
        return 'hef://app/my_products';
      case 'my_feeds':
        return 'hef://app/my_feeds';
      case 'mainpage':
        return 'hef://app/mainpage';

      default:
        return null;
    }
  }
}
