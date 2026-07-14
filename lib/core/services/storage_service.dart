import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static final StorageService _instance = StorageService._();
  StorageService._();
  static StorageService get instance => _instance;

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> setToken(String token) async {
    await init();
    await _prefs!.setString('auth_token', token);
  }

  String? getToken() {
    if (_prefs == null) return null;
    return _prefs!.getString('auth_token');
  }

  Future<void> setLanguage(String code) async {
    await init();
    await _prefs!.setString('lang', code);
  }

  String getLanguage() {
    if (_prefs == null) return 'en';
    return _prefs!.getString('lang') ?? 'en';
  }

  Future<void> setLocation(double lat, double lng) async {
    await init();
    await _prefs!.setDouble('lat', lat);
    await _prefs!.setDouble('lng', lng);
  }

  double? getLatitude() {
    if (_prefs == null) return null;
    return _prefs!.getDouble('lat');
  }

  double? getLongitude() {
    if (_prefs == null) return null;
    return _prefs!.getDouble('lng');
  }

  Future<void> setZoneIds(List<int> zones) async {
    await init();
    await _prefs!.setString('zoneIds', jsonEncode(zones));
  }

  List<int> getZoneIds() {
    if (_prefs == null) return const [];
    final raw = _prefs!.getString('zoneIds');
    if (raw == null || raw.isEmpty) return const [];
    try {
      final list = (jsonDecode(raw) as List).cast<num>().map((e) => e.toInt()).toList();
      return list;
    } catch (_) {
      return const [];
    }
  }
}

