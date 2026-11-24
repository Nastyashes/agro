import '../api.dart';

class Auth extends Api {
  Future<ApiAnswer> loginNumber({required String number}) => send('auth',
      query: {'phone': legacyQueryValue(number)}, handleUnauthorized: false);

  Future<ApiAnswer> loginCode({required String code}) => send('auth',
      query: {'code': legacyQueryValue(code)}, handleUnauthorized: false);
}
