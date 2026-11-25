import 'dart:io';

import 'package:agro/data/session_storage.dart';
import 'package:agro/model/model_user/model_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

/// Contract: one place owns the persisted session (user + token, country,
/// language). A session is active only with both a country and a token.
void main() {
  late Directory dir;
  late Box box;
  late SessionStorage storage;

  setUpAll(() {
    dir = Directory.systemTemp.createTempSync('session_storage_test');
    Hive.init(dir.path);
    Hive.registerAdapter(ModelUserAdapter());
  });

  setUp(() async {
    box = await Hive.openBox('data_test');
    await box.clear();
    storage = SessionStorage(box);
  });

  tearDownAll(() async {
    await Hive.close();
    dir.deleteSync(recursive: true);
  });

  test('empty storage: no user, no token, default language, no session', () {
    expect(storage.user, isNull);
    expect(storage.token, '');
    expect(storage.country, isNull);
    expect(storage.language, 'en');
    expect(storage.hasSession, isFalse);
  });

  test('saveUser persists the user and exposes the token', () async {
    await storage.saveUser(ModelUser(id: '9', name: 'Іван', token: 'T0K'));

    expect(SessionStorage(box).user!.name, 'Іван');
    expect(SessionStorage(box).token, 'T0K');
  });

  test('session needs both a country and a token', () async {
    await storage.saveCountry('ukraine');
    expect(storage.hasSession, isFalse);

    await storage.saveUser(ModelUser(id: '9', token: 'T0K'));
    expect(storage.hasSession, isTrue);
  });

  test('a user without a token is not a session', () async {
    await storage.saveCountry('ukraine');
    await storage.saveUser(ModelUser(id: '9'));

    expect(storage.hasSession, isFalse);
  });

  test('language is saved, and null keeps the default', () async {
    await storage.saveLanguage('uk');
    expect(storage.language, 'uk');

    await storage.saveLanguage(null);
    expect(storage.language, 'en');
  });

  test('clear removes everything', () async {
    await storage.saveCountry('kazakh');
    await storage.saveLanguage('kk');
    await storage.saveUser(ModelUser(id: '9', token: 'T0K'));

    await storage.clear();

    expect(storage.user, isNull);
    expect(storage.country, isNull);
    expect(storage.language, 'en');
    expect(storage.hasSession, isFalse);
  });

  test('a non-user value under the user key is ignored', () async {
    await box.put('modelUser', 'garbage');

    expect(storage.user, isNull);
    expect(storage.token, '');
  });
}
