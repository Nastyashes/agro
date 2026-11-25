import 'package:agro/model/model_user/model_user.dart';
import 'package:hive/hive.dart';

/// The only owner of the persisted session: signed-in user (with token),
/// selected country and UI language. Backed by the Hive box `data`.
class SessionStorage {
  SessionStorage([Box? box]) : _boxOverride = box;

  /// Shared instance over the app's `data` box (opened in `main`).
  static final SessionStorage instance = SessionStorage();

  static const _userKey = 'modelUser';
  static const _countryKey = 'selectedCountry';
  static const _languageKey = 'language';

  final Box? _boxOverride;

  Box get _box => _boxOverride ?? Hive.box('data');

  ModelUser? get user {
    final value = _box.get(_userKey);
    return value is ModelUser ? value : null;
  }

  /// Session token, or '' when signed out.
  String get token => user?.token ?? '';

  /// `Country.name` chosen on the first screen.
  String? get country => _box.get(_countryKey) as String?;

  String get language => (_box.get(_languageKey) as String?) ?? 'en';

  /// Signed in and a country is chosen: the app can open the home screen.
  bool get hasSession => country != null && user?.token != null;

  Future<void> saveUser(ModelUser user) => _box.put(_userKey, user);

  Future<void> saveCountry(String country) => _box.put(_countryKey, country);

  Future<void> saveLanguage(String? language) => language == null
      ? _box.delete(_languageKey)
      : _box.put(_languageKey, language);

  /// Signs out and forgets country and language.
  Future<void> clear() => _box.clear();
}
