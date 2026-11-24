import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;

/// Where `method`, `key` and `lang` travel.
///
/// [query]: in the URL (legacy `apiapp.php` endpoints).
/// [body]: as multipart fields (newer `api.php` endpoints).
enum ApiTransport { query, body }

enum ApiErrorKind { network, timeout, badResponse }

class ApiException implements Exception {
  final ApiErrorKind kind;
  final int? statusCode;
  final Object? cause;

  const ApiException(this.kind, {this.statusCode, this.cause});

  @override
  String toString() =>
      'ApiException(${kind.name}${statusCode == null ? '' : ', $statusCode'}'
      '${cause == null ? '' : ': $cause'})';
}

class ApiResponse {
  final int statusCode;

  /// Decoded JSON body.
  final dynamic data;

  const ApiResponse(this.statusCode, this.data);
}

/// Single entry point for all backend calls: builds the request, applies a
/// timeout, decodes JSON and reports expired sessions.
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    required this.baseUrl,
    required this.token,
    required this.language,
    this.onUnauthorized,
    this.timeout = const Duration(seconds: 30),
  }) : _http = httpClient ?? http.Client();

  final http.Client _http;
  final String Function() baseUrl;
  final String Function() token;
  final String Function() language;
  final void Function()? onUnauthorized;
  final Duration timeout;

  Future<ApiResponse> post(
    String method, {
    String endpoint = 'apiapp.php',
    ApiTransport transport = ApiTransport.query,
    Map<String, String> query = const {},
    Map<String, String> fields = const {},
    bool withLang = true,
    bool handleUnauthorized = true,
  }) async {
    final base = <String, String>{
      'method': method,
      'key': token(),
    };
    final lang = withLang ? {'lang': language()} : const <String, String>{};

    final queryParams =
        transport == ApiTransport.query ? {...base, ...query, ...lang} : query;
    final bodyFields =
        transport == ApiTransport.body ? {...base, ...lang, ...fields} : fields;

    final uri = Uri.parse('${baseUrl()}$endpoint').replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final request = http.MultipartRequest('POST', uri)
      ..headers['Accept'] = 'application/json'
      ..fields.addAll(bodyFields);

    log('API $method ${uri.path} '
        'query=${_mask(queryParams)} fields=${_mask(bodyFields)}');

    final http.Response response;
    try {
      response = await _http
          .send(request)
          .then(http.Response.fromStream)
          .timeout(timeout);
    } on TimeoutException catch (e) {
      throw ApiException(ApiErrorKind.timeout, cause: e);
    } on http.ClientException catch (e) {
      throw ApiException(ApiErrorKind.network, cause: e);
    }

    final dynamic data;
    try {
      data = json.decode(utf8.decode(response.bodyBytes));
    } on FormatException catch (e) {
      throw ApiException(
        ApiErrorKind.badResponse,
        statusCode: response.statusCode,
        cause: e.message,
      );
    }

    if (handleUnauthorized &&
        data is Map &&
        data['message'] == 'Unauthorized') {
      onUnauthorized?.call();
    }

    return ApiResponse(response.statusCode, data);
  }

  static Map<String, String> _mask(Map<String, String> params) => {
        for (final e in params.entries)
          e.key:
              (e.key == 'key' || e.key == 'device_token') && e.value.isNotEmpty
                  ? '***'
                  : e.value,
      };
}
