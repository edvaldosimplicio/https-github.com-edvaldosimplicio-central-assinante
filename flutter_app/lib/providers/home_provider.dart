import 'package:flutter/material.dart';
import '../models/fatura_model.dart';
import '../models/conexao_model.dart';
import '../services/api_service.dart';
import '../services/financeiro_service.dart';
import '../services/conexao_service.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService _api;

  FinanceiroService? _financeiroService;
  ConexaoService? _conexaoService;

  FaturaModel? _faturaAberta;
  ConexaoModel? _conexao;
  bool _isLoading = false;
  String? _error;

  FaturaModel? get faturaAberta => _faturaAberta;
  ConexaoModel? get conexao => _conexao;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HomeProvider(this._api) {
    _financeiroService = FinanceiroService(_api);
    _conexaoService = ConexaoService(_api);
  }

  Future<void> loadHomeData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _financeiroService!.getFaturaAberta(),
        _conexaoService!.getStatus(),
      ]);

      _faturaAberta = results[0] as FaturaModel?;
      _conexao = results[1] as ConexaoModel;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> desbloquearConexao() async {
    try {
      await _conexaoService!.desbloquear();
      await loadHomeData();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  String get valorFaturaFormatado {
    if (_faturaAberta == null) return 'Nenhuma fatura';
    return 'R\$ ${_faturaAberta!.valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get dataVencimentoFormatada {
    if (_faturaAberta == null || _faturaAberta!.vencimento.isEmpty) return '';
    final partes = _faturaAberta!.vencimento.split('-');
    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }
    return _faturaAberta!.vencimento;
  }
}
