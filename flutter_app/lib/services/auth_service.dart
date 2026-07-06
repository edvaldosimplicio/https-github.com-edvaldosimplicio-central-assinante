import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _api;

  AuthService(this._api);

  Future<Map<String, dynamic>> login(String cpfCnpj, [String? provedorSlug]) async {
    final body = <String, dynamic>{
      'cpf_cnpj': cpfCnpj,
    };
    if (provedorSlug != null) {
      body['provedor_slug'] = provedorSlug;
    }
    final response = await _api.post('/auth/login', body);

    if (response.containsKey('token')) {
      await _storage.write(key: 'auth_token', value: response['token']);
      await _storage.write(key: 'provedor_id', value: response['provedor']['id'].toString());
      await _storage.write(key: 'usuario_nome', value: response['usuario']['nome']);
    }

    return response;
  }

  Future<String?> getToken() => _storage.read(key: 'auth_token');
  Future<String?> getProvedorId() => _storage.read(key: 'provedor_id');
  Future<String?> getUsuarioNome() => _storage.read(key: 'usuario_nome');

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
