import '../models/conexao_model.dart';
import 'api_service.dart';

class ConexaoService {
  final ApiService _api;

  ConexaoService(this._api);

  Future<ConexaoModel> getStatus() async {
    final response = await _api.get('/conexao/status');
    return ConexaoModel.fromJson(response);
  }

  Future<Map<String, dynamic>> desbloquear() async {
    return await _api.post('/conexao/desbloquear', {});
  }
}
