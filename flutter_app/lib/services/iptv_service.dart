import '../models/canal_model.dart';
import 'api_service.dart';

class IptvService {
  final ApiService _api;

  IptvService(this._api);

  Future<List<CanalModel>> getCanais() async {
    final response = await _api.get('/iptv/canais');
    final list = response['channels'] as List<dynamic>? ?? [];
    return list.map((c) => CanalModel.fromJson(c)).toList();
  }
}
