import '../models/fatura_model.dart';
import 'api_service.dart';

class FinanceiroService {
  final ApiService _api;

  FinanceiroService(this._api);

  Future<FaturaModel?> getFaturaAberta() async {
    final response = await _api.get('/financeiro/resumo');
    if (response['faturaAberta'] != null) {
      return FaturaModel.fromJson(response['faturaAberta']);
    }
    return null;
  }

  Future<List<FaturaModel>> getHistorico() async {
    final response = await _api.get('/financeiro/historico');
    final list = response['faturas'] as List<dynamic>;
    return list.map((f) => FaturaModel.fromJson(f)).toList();
  }
}
