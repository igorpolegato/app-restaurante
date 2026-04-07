import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _keyCustomerId = 'customer_id';
  static const _keyMesa = 'mesa';
  static const _keyCustomerName = 'customer_name';

  static Future<void> saveSession({
    required int customerId,
    required int mesa,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyCustomerId, customerId);
    await prefs.setInt(_keyMesa, mesa);
    await prefs.setString(_keyCustomerName, name);
  }

  static Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final customerId = prefs.getInt(_keyCustomerId);
    final mesa = prefs.getInt(_keyMesa);
    if (customerId == null || mesa == null) return null;
    return {
      'customerId': customerId,
      'mesa': mesa,
      'name': prefs.getString(_keyCustomerName) ?? 'Cliente',
    };
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCustomerId);
    await prefs.remove(_keyMesa);
    await prefs.remove(_keyCustomerName);
  }
}
