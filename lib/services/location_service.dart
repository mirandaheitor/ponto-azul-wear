import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class LocationService {
  Future<Position> obterLocalizacaoAtual() async {
    await _isLocationServiceEnabled();
    await _ensureLocationPermission();

    final position = defaultTargetPlatform == TargetPlatform.android
        ? await _obterPosicaoAndroid()
        : await _tryCurrentPosition(forceAndroidLocationManager: false);

    if (position != null) {
      return position;
    }

    throw const LocationServiceException(
      'Não foi possível ler o GPS. No emulador Wear, envie a posição e tente novamente.',
    );
  }

  Future<Position?> _obterPosicaoAndroid() async {
    final attempts = <Future<Position?> Function()>[
      () => _tryCurrentPosition(forceAndroidLocationManager: true),
      () => _tryLastKnownPosition(forceAndroidLocationManager: true),
      () => _tryCurrentPosition(forceAndroidLocationManager: false),
      () => _tryLastKnownPosition(forceAndroidLocationManager: false),
    ];

    for (final attempt in attempts) {
      final position = await attempt();
      if (position != null) {
        return position;
      }
    }

    return null;
  }

  Future<Position?> _tryCurrentPosition({
    required bool forceAndroidLocationManager,
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: _locationSettings(
          forceAndroidLocationManager: forceAndroidLocationManager,
        ),
      );
    } on TimeoutException {
      return null;
    } on PlatformException {
      return null;
    } on LocationServiceDisabledException {
      return null;
    } on Exception {
      return null;
    }
  }

  Future<Position?> _tryLastKnownPosition({
    required bool forceAndroidLocationManager,
  }) async {
    try {
      return await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: forceAndroidLocationManager,
      );
    } on PlatformException {
      return null;
    } on LocationServiceDisabledException {
      return null;
    } on Exception {
      return null;
    }
  }

  LocationSettings _locationSettings({
    required bool forceAndroidLocationManager,
  }) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
        forceLocationManager: forceAndroidLocationManager,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 10),
    );
  }

  Future<bool> _isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } on PlatformException catch (error) {
      if (defaultTargetPlatform == TargetPlatform.android &&
          error.code == 'LOCATION_SERVICES_DISABLED') {
        return false;
      }
      throw LocationServiceException(_mapPlatformException(error));
    }
  }

  Future<void> _ensureLocationPermission() async {
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationServiceException('Permissão de localização negada.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationServiceException(
        'Permissão de localização negada permanentemente.',
      );
    }
  }

  String _mapPlatformException(PlatformException error) {
    if (error.code == 'LOCATION_SERVICES_DISABLED') {
      return 'Defina uma posição GPS no emulador Wear OS.';
    }
    return 'Não foi possível acessar a localização.';
  }
}
