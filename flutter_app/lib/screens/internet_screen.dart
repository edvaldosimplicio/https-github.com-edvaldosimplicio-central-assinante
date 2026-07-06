import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/connection_status_card.dart';

class InternetScreen extends StatefulWidget {
  const InternetScreen({super.key});

  @override
  State<InternetScreen> createState() => _InternetScreenState();
}

class _InternetScreenState extends State<InternetScreen> {
  bool _testingSpeed = false;
  double _speedValue = 0.0;
  String _speedUnit = 'Mbps';

  Future<void> _runSpeedTest() async {
    setState(() {
      _testingSpeed = true;
      _speedValue = 0.0;
    });

    // Simulate speed test progress
    for (int i = 0; i <= 20; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
      setState(() {
        _speedValue = (i * 32.1) + (i % 2 == 0 ? 5 : -5);
      });
    }

    if (!mounted) return;
    setState(() {
      _speedValue = 642.5; // Final test result matching reference
      _testingSpeed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final homeProvider = context.watch<HomeProvider>();
    final appTheme = auth.provedorConfig?.theme ?? AppTheme();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minha Internet',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: appTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (homeProvider.conexao != null) ...[
              ConnectionStatusCard(
                conexao: homeProvider.conexao!,
                theme: appTheme,
                onDesbloquear: () async {
                  final success = await homeProvider.desbloquearConexao();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success
                            ? 'Desbloqueio realizado!'
                            : 'Erro ao desbloquear'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
            ],

            // ── Wi-Fi Card ──
            _buildSectionHeader('Gerenciar Wi-Fi', appTheme),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: appTheme.successColor.withValues(alpha: 0.1),
                          child: Icon(Icons.wifi_lock_rounded, color: appTheme.successColor),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rede Wi-Fi Principal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Frequência 2.4GHz & 5GHz',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    _buildWifiInfoRow('Nome da Rede (SSID)', 'NET+ ${auth.usuario?.primeiroNome ?? 'Cliente'}', Icons.edit_rounded, appTheme),
                    const SizedBox(height: 16),
                    _buildWifiInfoRow('Senha do Wi-Fi', '••••••••••••', Icons.visibility_rounded, appTheme),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // Modal/Ação de alteração
                          _showWifiEditBottomSheet(context, appTheme);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appTheme.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Alterar Nome e Senha'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Speed Test Card ──
            _buildSectionHeader('Medidor de Velocidade', appTheme),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: appTheme.primaryColor.withValues(alpha: 0.05),
                              border: Border.all(
                                color: _testingSpeed
                                    ? appTheme.successColor
                                    : appTheme.primaryColor.withValues(alpha: 0.1),
                                width: 8,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _speedValue.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: appTheme.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    _speedUnit,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Teste sua velocidade de conexão',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Será feito um download e upload temporário.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 180,
                            child: ElevatedButton.icon(
                              onPressed: _testingSpeed ? null : _runSpeedTest,
                              icon: const Icon(Icons.speed_rounded, size: 20),
                              label: Text(_testingSpeed ? 'Testando...' : 'Iniciar Teste'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _testingSpeed
                                    ? Colors.grey
                                    : appTheme.successColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppTheme theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildWifiInfoRow(String label, String value, IconData icon, AppTheme theme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(icon, color: theme.primaryColor, size: 20),
          onPressed: () {},
        ),
      ],
    );
  }

  void _showWifiEditBottomSheet(BuildContext context, AppTheme theme) {
    final nameController = TextEditingController(text: 'NET+ João');
    final passController = TextEditingController(text: 'minhasenha123');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Alterar Wi-Fi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nome da Rede (SSID)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nova Senha',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Configuração enviada ao roteador! Pode levar até 2 minutos para aplicar.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Salvar Alterações'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
