import 'package:shared_preferences/shared_preferences.dart';

class Selected_Language {
  static late SharedPreferences pref_language;

  static Future init() async =>
      pref_language = await SharedPreferences.getInstance();

  static Future setLanguage(String lang) async =>
      await pref_language.setString('Language', lang);

  static String? getLanguage() {
    return pref_language.getString('Language');
  }
}

class Theme_pref {
  static late SharedPreferences pref_theme;

  static Future init() async =>
      pref_theme = await SharedPreferences.getInstance();

  static Future setTheme(int theme) async =>
      await pref_theme.setInt('Theme', theme);

  static int? getTheme() {
    return pref_theme.getInt('Theme');
  }
}

class Token_pref {
  static late SharedPreferences pref_token;

  static Future init() async =>
      pref_token = await SharedPreferences.getInstance();

  static Future setToken(String token) async =>
      await pref_token.setString('Token', token);

  static String? getToken() {
    return pref_token.getString('Token');
  }

  static Future<bool> removeToken() async =>
      await pref_token.remove('Token');
}

class User_pref {
  static late SharedPreferences pref_user;

  static Future init() async =>
      pref_user = await SharedPreferences.getInstance();

  static Future setUser(String user) async =>
      await pref_user.setString('User', user);

  static String? getUser() {
    return pref_user.getString('User');
  }

  static Future<bool> removeUser() async =>
      await pref_user.remove('User');
}

class Bool_pref {
  static late SharedPreferences pref_bool;

  static Future init() async =>
      pref_bool = await SharedPreferences.getInstance();

  static Future setBool(String key, bool value) async =>
      await pref_bool.setBool(key, value);

  static bool? getBool(String key) {
    return pref_bool.getBool(key);
  }
}
