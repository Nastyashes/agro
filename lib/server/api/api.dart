import 'package:agro/controllers/session_end.dart';
import 'package:agro/data/session_storage.dart';
import 'package:agro/auth/country/country_screen.dart';
import 'package:agro/server/api/api_client.dart';
import 'package:agro/server/api/controller/common.dart';
import 'package:flutter/foundation.dart';

import '../../routes/app_pages.dart';
import 'controller/auth.dart';
import 'controller/fermer.dart';
import 'controller/my_price.dart';
import 'controller/traider.dart';

class Api {
  static ApiClient _client = _defaultClient();

  /// Shared transport for every API group. Tests replace it with a fake.
  static ApiClient get client => _client;

  @visibleForTesting
  static set client(ApiClient value) => _client = value;

  static ApiClient _defaultClient() => ApiClient(
        baseUrl: baseUrl,
        token: _token,
        language: language,
        onUnauthorized: _onUnauthorized,
      );

  static String baseUrl() {
    return SessionStorage.instance.country == Country.kazakh.name
        ? 'https://uagro.kz/'
        : 'https://uagro.trade/';
  }

  static String language() => SessionStorage.instance.language;

  static String _token() => SessionStorage.instance.token;

  /// Expired or revoked token: drop the session (not the country, which
  /// picks the backend) and the previous user's cached data.
  static void _onUnauthorized() {
    endSession(keepCountry: true, route: Routes.auth);
  }

  /// Sends [method] and wraps the result in the legacy [ApiAnswer].
  @protected
  Future<ApiAnswer> send(
    String method, {
    String endpoint = 'apiapp.php',
    ApiTransport transport = ApiTransport.query,
    Map<String, String> query = const {},
    Map<String, String> fields = const {},
    bool withLang = true,
    bool handleUnauthorized = true,
  }) async {
    final response = await client.post(
      method,
      endpoint: endpoint,
      transport: transport,
      query: query,
      fields: fields,
      withLang: withLang,
      handleUnauthorized: handleUnauthorized,
    );
    return ApiAnswer()
      ..code = response.statusCode
      ..data = response.data;
  }

  Auth get auth => Auth();

  Fermer get fermer => Fermer();

  Traider get traider => Traider();

  MyPriceApi get myPrice => MyPriceApi();

  Commmon get common => Commmon();
}

/// Reproduces how the legacy raw-URL code sent [value]: an unescaped `+` in
/// a query string is decoded by PHP as a space. Login endpoints rely on that
/// exact server-side input, so they keep it until the backend confirms
/// otherwise.
String legacyQueryValue(String value) => value.replaceAll('+', ' ');

class ApiAnswer {
  int? code;
  dynamic data;
}

/// Ends the session when [data] says the token is no longer valid.
void checkAuth(dynamic data) {
  if (data is Map && data['message'] == 'Unauthorized') {
    Api._onUnauthorized();
  }
}
