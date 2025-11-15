import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _gridTypeKey = 'grid_type';
  static const String _autoBackupKey = 'auto_backup';
  static const String _autoBackupWifiOnlyKey = 'auto_backup_wifi_only';
  static const String _imageQualityKey = 'image_quality';
  static const String _maxCacheSizeKey = 'max_cache_size';

  final SharedPreferences _prefs;
  
  SettingsProvider(this._prefs);

  static Future<SettingsProvider> create() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsProvider(prefs);
  }

  ThemeMode get themeMode {
    final value = _prefs.getString(_themeKey) ?? 'system';
    return ThemeMode.values.firstWhere(
      (mode) => mode.toString() == 'ThemeMode.$value',
      orElse: () => ThemeMode.system,
    );
  }

  set themeMode(ThemeMode mode) {
    _prefs.setString(_themeKey, mode.toString().split('.').last);
    notifyListeners();
  }

  String get gridType => _prefs.getString(_gridTypeKey) ?? 'staggered';
  
  set gridType(String type) {
    _prefs.setString(_gridTypeKey, type);
    notifyListeners();
  }

  bool get autoBackup => _prefs.getBool(_autoBackupKey) ?? false;
  
  set autoBackup(bool value) {
    _prefs.setBool(_autoBackupKey, value);
    notifyListeners();
  }

  bool get autoBackupWifiOnly => _prefs.getBool(_autoBackupWifiOnlyKey) ?? true;
  
  set autoBackupWifiOnly(bool value) {
    _prefs.setBool(_autoBackupWifiOnlyKey, value);
    notifyListeners();
  }

  int get imageQuality => _prefs.getInt(_imageQualityKey) ?? 85;
  
  set imageQuality(int value) {
    _prefs.setInt(_imageQualityKey, value);
    notifyListeners();
  }

  int get maxCacheSize => _prefs.getInt(_maxCacheSizeKey) ?? 1024; // In MB
  
  set maxCacheSize(int value) {
    _prefs.setInt(_maxCacheSizeKey, value);
    notifyListeners();
  }
}