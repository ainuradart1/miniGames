import 'package:shared_preferences/shared_preferences.dart';

class RecordsService {
  static const String _prefix = 'record_';

  static Future<int> getRecord(String gameKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_prefix$gameKey') ?? 0;
  }

  static Future<void> saveRecord(String gameKey, int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getRecord(gameKey);
    if (score > current) {
      await prefs.setInt('$_prefix$gameKey', score);
    }
  }

  static Future<Map<String, int>> getAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = ['math_quiz', 'tap_game', 'memory_game'];
    final Map<String, int> records = {};
    for (final key in keys) {
      records[key] = prefs.getInt('$_prefix$key') ?? 0;
    }
    return records;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = ['math_quiz', 'tap_game', 'memory_game'];
    for (final key in keys) {
      await prefs.remove('$_prefix$key');
    }
  }
}