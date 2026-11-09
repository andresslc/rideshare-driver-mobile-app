import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../di/service_locator.dart';
import '../navigation/app_router.dart';
import '../utils/app_log.dart';
import 'notification_route_service.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log("Handling background message: ${message.messageId}");
}

class NotificationServices {
  final StorageService prefs = locator<StorageService>();
  late NotificationSettings notificationSettings;
  Map<String, dynamic>? pendingNotificationData;
  final StreamController<Map<String, dynamic>> _payloadController =
      StreamController<Map<String, dynamic>>.broadcast();
  NotificationServices();
  Future<void> init() async {
    await requestNotificationPermission();
    await firebaseInit();
    await initLocalNotifications();
  }

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'driver_app_notification',
    'High Importance Channel Name',
    description: 'High IMportance',
    importance: Importance.max,
  );

  Stream<Map<String, dynamic>> get notificationPayloadStream =>
      _payloadController.stream;

  Future<void> requestNotificationPermission() async {
    if (Platform.isIOS) {
      notificationSettings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    } else if (Platform.isAndroid) {
      notificationSettings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }
    // log("AUTHORIZED${settings.authorizationStatus}");
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      debugPrint('Permission Granted');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      debugPrint('Permission Approved');
    } else {
      debugPrint('Permission Denied');
    }
  }

  Future<String?> getDeviceToken() async {
    // log("${await FirebaseMessaging.instance.getToken()}");
    try {
      final String? token = await FirebaseMessaging.instance.getToken();

      if (token != null) {
        debugPrint('FCM $token');
        await locator<StorageService>().setFCMToken(token);
        return token;
      } else {
        debugPrint('FCM TOKEN IS NULL!');
      }
      debugPrint('FCM TOKENNN $token');
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> firebaseInit() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
    FirebaseMessaging.onMessage.listen((message) {
      log(" :::::::onMessage::::::::::::::::::: ${message.data}", name: 'FCM');
      _payloadController.add(Map<String, dynamic>.from(message.data));
      locator<NotificationRouteService>().syncRideStateFromNotification(
        Map<String, dynamic>.from(message.data),
      );
      if (message.notification != null) {
        if (Platform.isAndroid) {
          showNotification(message);
        }
      }
    });

    await setupInteractMessage();
  }

  Future<void> setupInteractMessage() async {
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance
        .getInitialMessage();
    if (initialMessage != null) {
      log(name: "FCM", "Opened from terminated: ${initialMessage.data}");
      pendingNotificationData = initialMessage.data;
      final Map<String, dynamic> payload = Map<String, dynamic>.from(
        initialMessage.data,
      );
      _payloadController.add(payload);
      locator<NotificationRouteService>().syncRideStateFromNotification(
        payload,
      );
    }
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      _payloadController.add(Map<String, dynamic>.from(event.data));
      _logNotificationTap(
        source: 'background Notification',
        payload: event.data,
        messageId: event.messageId,
      );
      navigate(
        payload: event.data,
        title: event.notification?.title,
        body: event.notification?.body,
      );

      log(
        " :::::::onMessageOpenedApp::::::::::::::::::: ${event.data}",
        name: 'FCM',
      );
    });
  }

  // void navigateToMusic({required MusicModel music}) {
  //   log("navigateToMusic ::::::::::::::first::::;;");
  //   BuildContext? context = ContextUtility.context;
  //   // if (context != null) {
  //   if (context != null) {
  //     if (music.type != 'upcoming') {
  //       context.read<MusicPlayerBloc>().add(
  //         OnSongLoadEvent(musics: [music], currentMusicId: music.sId ?? ''),
  //       );
  //       Navigate.toMusicDetail(context);
  //     } else {
  //       Navigate.toUpcomingDetail(
  //         context,
  //         extra: UpcommingDetailDto(music: music),
  //       );
  //     }
  //   }
  //   log("navigateToMusic ::::::::::::::last::::;;");
  // }

  Future<void> initLocalNotifications() async {
    const androidInitializationSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const DarwinInitializationSettings iosInit = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    const InitializationSettings initSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInit,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,

      onDidReceiveNotificationResponse: (response) {
        debugPrint("🔥 FOREGROUND TAP DETECTED");

        final payloadString = response.payload;

        debugPrint("📦 RAW PAYLOAD: $payloadString");

        if (payloadString == null || payloadString.isEmpty) {
          debugPrint("❌ Payload is empty");
          return;
        }

        try {
          final decoded = jsonDecode(payloadString);

          debugPrint("✅ DECODED PAYLOAD: $decoded");

          if (decoded is Map<String, dynamic>) {
            _logNotificationTap(source: 'foreground_local', payload: decoded);
            navigate(payload: decoded);
          } else {
            debugPrint("❌ Payload is not a valid map");
          }
        } catch (e) {
          debugPrint("❌ JSON decode failed: $e");
        }
      },
    );
  }

  Future<void> showNotification(RemoteMessage message) async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channel.id.toString(),
          channel.name.toString(),
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'harmonius',
          showProgress: true,
        );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: darwinNotificationDetails,
    );
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        message.notification.hashCode,
        message.notification!.title.toString(),
        message.notification!.body,
        payload: jsonEncode(message.data),
        notificationDetails,
      );
      log(':::::::::::::::::::: ${message.data}');
    });
  }

  /// Process and navigate any pending notification payload saved when the app was launched or context was not ready
  void processPendingNotificationIfAny() {
    final Map<String, dynamic>? data = pendingNotificationData;
    if (data != null && data.isNotEmpty) {
      log('Processing pending notification data: $data', name: 'FCM');
      pendingNotificationData = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigate(payload: data);
      });
    }
  }

  /// Navigate based on notification payload
  void navigate({Map<String, dynamic>? payload, String? title, String? body}) {
    if (payload == null || payload.isEmpty) return;

    final BuildContext? context = rootNavigatorKey.currentContext;
    if (context == null) {
      log(
        'Notification tap received before navigator was ready. Storing as pending notification. Payload: $payload',
        name: 'FCM',
      );
      pendingNotificationData = payload;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        processPendingNotificationIfAny();
      });
      return;
    }

    if (kDebugMode) {
      log('payload is $payload', name: 'FCM');
    }

    try {
      locator<NotificationRouteService>().handleNotificationTap(
        context,
        payload,
      );
    } catch (e, st) {
      debugPrint("🔥 Failed to navigate from payload: $e\n$st");
    }
  }

  void _logNotificationTap({
    required String source,
    required Map<String, dynamic> payload,
    String? messageId,
  }) {
    final List<String> details = <String>[
      'Notification tap detected',
      'source=$source',
      if (messageId != null && messageId.isNotEmpty) 'messageId=$messageId',
      'payload=$payload',
    ];
    log(details.join(' | '), name: 'FCM');
  }
}
