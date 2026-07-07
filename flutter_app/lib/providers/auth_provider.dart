import 'package:flutter/material.dart';
import '../core/app_config.dart';
import '../models/usuario_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../theme/white_label_config.dart';

class AuthProvider extends ChangeNotifier {
  AuthService? _authService;
  UsuarioModel? _usuario;
  WhiteLabelConfig? _provedorConfig;
  String? _token;
  bool _isLoading = false;
  String? _error;
  bool _initialized = false;

  UsuarioModel? get usuario => _usuario;
  WhiteLabelConfig? get provedorConfig => _provedorConfig;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _usuario != null && _token != null;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    final baseUrl = await AppConfig.getBaseUrl();
    final api = ApiService(baseUrl: baseUrl);
    _authService = AuthService(api);

    // Try auto-login with saved token
    final savedToken = await _authService!.getToken();
    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
      final savedNome = await _authService!.getUsuarioNome();
      if (savedNome != null) {
        _usuario = UsuarioModel(nome: savedNome, cpfCnpj: '');
      }
    }

    _initialized = true;
    notifyListeners();
  }

  Future<bool> login(String cpfCnpj, [String? provedorSlug]) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    if (provedorSlug == null) {
      provedorSlug = await AppConfig.getSlug();
    }

    try {
      final response = await _authService!.login(cpfCnpj, provedorSlug);

      _token = response['token'];
      _usuario = UsuarioModel.fromJson(response['usuario']);
      _provedorConfig = WhiteLabelConfig.fromJson(response['provedor']);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService?.logout();
    _usuario = null;
    _provedorConfig = null;
    _token = null;
    notifyListeners();
  }
}
