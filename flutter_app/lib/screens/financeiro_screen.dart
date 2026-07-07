import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/financeiro_service.dart';
import '../models/fatura_model.dart';
import '../theme/app_theme.dart';

class FinanceiroScreen extends StatefulWidget {
  const FinanceiroScreen({super.key});

  @override
  State<FinanceiroScreen> createState() => _FinanceiroScreenState();
}

class _FinanceiroScreenState extends State<FinanceiroScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FaturaModel> _faturas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistorico();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadHistorico() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final api = ApiService(
        baseUrl: 'http://38.250.217.82:3000/api',
        token: auth.token,
        provedorId: auth.provedorConfig?.slug,
      );
      final service = FinanceiroService(api);
      final list = await service.getHistorico();
      if (mounted) {
        setState(() {
          _faturas = list;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar histórico: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Fallback to mock data if API fails (local development)
        setState(() {
          _faturas = [
            FaturaModel(
              id: '1',
              valor: 105.00,
              vencimento: '2026-07-09',
              status: 'aberto',
              mesReferencia: 'Jul/2026',
              pixCopiaECola: '00020101021226830014br.gov.bcb.pix2561api.pix.provedor.com/qr/v2/cobv/73ea3716fd9d424b95f2425',
            ),
            FaturaModel(
              id: '2',
              valor: 105.00,
              vencimento: '2026-06-09',
              status: 'pago',
              mesReferencia: 'Jun/2026',
              pagamento: '2026-06-08',
            ),
            FaturaModel(
              id: '3',
              valor: 105.00,
              vencimento: '2026-05-09',
              status: 'pago',
              mesReferencia: 'Mai/2026',
              pagamento: '2026-05-07',
            ),
          ];
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final appTheme = auth.provedorConfig?.theme ?? AppTheme();

    final faturasAbertas = _faturas.where((f) => f.estaAberta).toList();
    final faturasPagas = _faturas.where((f) => f.estaPaga).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Financeiro',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: appTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          tabs: const [
            Tab(text: 'Em Aberto'),
            Tab(text: 'Pagas'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildInvoiceList(faturasAbertas, appTheme, isPending: true),
                _buildInvoiceList(faturasPagas, appTheme, isPending: false),
              ],
            ),
    );
  }

  Widget _buildInvoiceList(List<FaturaModel> list, AppTheme theme, {required bool isPending}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.check_circle_outline_rounded : Icons.history_rounded,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              isPending ? 'Nenhuma fatura em aberto!' : 'Nenhuma fatura paga encontrada',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final fatura = list[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isPending
                            ? theme.warningColor.withValues(alpha: 0.1)
                            : theme.successColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isPending ? Icons.pending_actions_rounded : Icons.check_circle_rounded,
                        color: isPending ? theme.warningColor : theme.successColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fatura.mesReferencia ?? 'Fatura Mensal',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isPending
                                ? 'Vence em: ${_formatarData(fatura.vencimento)}'
                                : 'Paga em: ${_formatarData(fatura.pagamento ?? fatura.vencimento)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'R\$ ${fatura.valor.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isPending ? theme.primaryColor : theme.successColor,
                      ),
                    ),
                  ],
                ),
                if (isPending && fatura.pixCopiaECola != null) ...[
                  const Divider(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: fatura.pixCopiaECola!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('PIX Copia e Cola copiado!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_rounded, size: 18),
                          label: const Text('Copiar PIX'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.secondaryColor,
                            side: BorderSide(color: theme.secondaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      if (fatura.linkBoleto != null && fatura.linkBoleto!.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {}, // Open PDF link
                            icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                            label: const Text('Boleto PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatarData(String data) {
    final partes = data.split('-');
    if (partes.length == 3) {
      return '${partes[2]}/${partes[1]}/${partes[0]}';
    }
    return data;
  }
}
