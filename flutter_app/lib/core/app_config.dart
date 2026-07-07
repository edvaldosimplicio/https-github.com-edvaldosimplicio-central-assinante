import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  static const String _baseUrlKey = 'api_base_url';
  static const String _slugKey = 'provedor_slug';

  static const String defaultBaseUrl = 'http://38.250.217.82:3000/api';
  static const String defaultSlug = 'redemeganet';

  static Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_baseUrlKey) ?? defaultBaseUrl;
  }

  static Future<String> getSlug() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_slugKey) ?? defaultSlug;
  }

  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_baseUrlKey, url);
  }

  static Future<void> setSlug(String slug) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_slugKey, slug);
  }
}
