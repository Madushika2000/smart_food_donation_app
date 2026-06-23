import 'package:shared_preferences/shared_preferences.dart';

/// The outcome of checking a login attempt against the saved account.
/// Each value maps to a specific, user-friendly error message on the
/// Login screen (see [CurrentUser.validateLogin]).
enum LoginResult {
  success, // identity + password both correct
  wrongIdentity, // password matches, but the username/email does not
  wrongPassword, // username/email matches, but the password does not
  wrongBoth, // neither the username/email nor the password match
  noAccount, // nobody has signed up on this device yet
}

/// Stores the logged-in user's details.
///
/// The values are kept in memory while the app runs, AND saved to the
/// device using shared_preferences so they are remembered after the app
/// is closed and reopened. This is why the Home/Profile screens can show
/// the real user (e.g. "Madushika") instead of "Guest" after a restart.
///
/// No Firebase / online backend yet — everything is stored locally.
class CurrentUser {
  // The details of the user who is currently logged in.
  static String name = "Guest User";
  static String email = "";
  static String phone = "";
  static String location = "Colombo, Sri Lanka";

  // The account password set at signup. Kept locally only so login can be
  // validated offline. NOTE: this is a demo (no backend) — a real app must
  // never store a plaintext password; hash it server-side instead.
  static String password = "";

  // The keys used to save each value on the device.
  static const String _kName = "user_name";
  static const String _kEmail = "user_email";
  static const String _kPhone = "user_phone";
  static const String _kLocation = "user_location";
  static const String _kPassword = "user_password";

  /// True once someone has signed up on this device (so login can be checked).
  static bool get hasAccount => password.isNotEmpty && email.isNotEmpty;

  /// Just the first word of the name (e.g. "Madushika Perera" -> "Madushika").
  /// Used for the short greeting on the Home dashboard.
  static String get firstName {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) return "Guest";
    return trimmed.split(' ').first;
  }

  /// Loads any previously saved user from the device into memory.
  /// Call this once when the app starts (see main.dart).
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString(_kName) ?? "Guest User";
    email = prefs.getString(_kEmail) ?? "";
    phone = prefs.getString(_kPhone) ?? "";
    location = prefs.getString(_kLocation) ?? "Colombo, Sri Lanka";
    password = prefs.getString(_kPassword) ?? "";
  }

  /// Saves the current values to the device so they survive a restart.
  static Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, name);
    await prefs.setString(_kEmail, email);
    await prefs.setString(_kPhone, phone);
    await prefs.setString(_kLocation, location);
    await prefs.setString(_kPassword, password);
  }

  /// Saves the details captured during signup (or when editing the profile).
  static Future<void> setUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    String location = "Colombo, Sri Lanka",
  }) async {
    CurrentUser.name = name;
    CurrentUser.email = email;
    CurrentUser.phone = phone;
    CurrentUser.password = password;
    CurrentUser.location = location;
    await _save();
  }

  /// Checks a login attempt against the saved account.
  ///
  /// [identity] may be either the username (full name) or the email — the
  /// match is case-insensitive and ignores surrounding spaces. Returns a
  /// [LoginResult] the Login screen turns into a clear error message.
  static LoginResult validateLogin(String identity, String pass) {
    if (!hasAccount) return LoginResult.noAccount;

    final String id = identity.trim().toLowerCase();
    final bool identityOk =
        id == email.trim().toLowerCase() || id == name.trim().toLowerCase();
    final bool passwordOk = pass == password;

    if (identityOk && passwordOk) return LoginResult.success;
    if (!identityOk && !passwordOk) return LoginResult.wrongBoth;
    if (!identityOk) return LoginResult.wrongIdentity;
    return LoginResult.wrongPassword;
  }

  /// Updates only some fields (used by the Edit Profile screen), then saves.
  static Future<void> update({
    String? name,
    String? email,
    String? phone,
    String? location,
  }) async {
    if (name != null) CurrentUser.name = name;
    if (email != null) CurrentUser.email = email;
    if (phone != null) CurrentUser.phone = phone;
    if (location != null) CurrentUser.location = location;
    await _save();
  }

  /// Clears the saved user (used on logout).
  static Future<void> clear() async {
    name = "Guest User";
    email = "";
    phone = "";
    location = "Colombo, Sri Lanka";
    password = "";
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
