import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:logger/logger.dart';

class SoundService {
  FlutterSoundPlayer? _player;
  bool _isPlayerInitialized = false;
  final Map<String, Uint8List> _soundCache = <String, Uint8List>{};

  static const String rideSound = 'assets/sounds/ride_sound.mp3';

  Future<void> init() async {
    if (_isPlayerInitialized) return;
    try {
      _player = FlutterSoundPlayer(logLevel: Level.nothing);
      await _player!.openPlayer();
      _isPlayerInitialized = true;
      debugPrint('SoundService initialized successfully in Driver App.');
    } catch (e) {
      debugPrint('SoundService initialization failed: $e');
      _isPlayerInitialized = false;
    }
  }

  Future<Uint8List?> _loadSoundBytes(String assetPath) async {
    if (_soundCache.containsKey(assetPath)) {
      return _soundCache[assetPath];
    }
    try {
      final ByteData data = await rootBundle.load(assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      _soundCache[assetPath] = bytes;
      return bytes;
    } catch (e) {
      debugPrint('Error loading sound asset $assetPath: $e');
      return null;
    }
  }

  Future<void> _playSound(
    String assetPath, {
    VoidCallback? whenFinished,
  }) async {
    try {
      if (!_isPlayerInitialized) {
        await init();
      }
      if (_player == null || !_isPlayerInitialized) return;

      final Uint8List? bytes = await _loadSoundBytes(assetPath);
      if (bytes == null || bytes.isEmpty) return;

      if (_player!.isPlaying) {
        await _player!.stopPlayer();
      }

      await _player!.startPlayer(
        fromDataBuffer: bytes,
        codec: Codec.mp3,
        whenFinished: whenFinished,
      );
    } catch (e) {
      debugPrint('Error playing sound ($assetPath): $e');
    }
  }

  /// Plays ride sound + haptic feedback when a new incoming request arrives.
  Future<void> playRequestReceivedSound() async {
    try {
      await HapticFeedback.vibrate();
    } catch (e) {
      debugPrint('Haptic feedback error: $e');
    }
    await _playSound(rideSound);
  }

  /// Sound effect when ride is accepted.
  Future<void> playRideAcceptedSound() async {
    await _playSound(rideSound);
  }

  Future<void> playDriverArrivedSound() async {
    await _playSound(rideSound);
  }

  /// Sound effect when ride starts after pickup.
  Future<void> playRideStartedSound() async {
    await _playSound(rideSound);
  }

  /// Sound effect when ride is completed.
  Future<void> playRideCompletedSound() async {
    await _playSound(rideSound);
  }

  /// Sound effect when ride is cancelled.
  Future<void> playRideCancelledSound() async {
    await _playSound(rideSound);
  }

  Future<void> dispose() async {
    _soundCache.clear();
    try {
      if (_player != null) {
        await _player!.closePlayer();
        _player = null;
      }
      _isPlayerInitialized = false;
    } catch (e) {
      debugPrint('Error disposing SoundService player: $e');
    }
  }
}
