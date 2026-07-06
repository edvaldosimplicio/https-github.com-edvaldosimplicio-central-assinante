import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../theme/app_theme.dart';
import '../models/conexao_model.dart';
import '../models/fatura_model.dart';
import '../widgets/app_header.dart';
import '../widgets/connection_status_card.dart';
import '../widgets/diagnose_card.dart';
import '../widgets/fatura_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/connected_devices_section.dart';
import '../widgets/referral_banner.dart';
import 'tv_screen.dart';
import '../widgets/menu_lateral_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthProvider>().isLoggedIn) {
        context.read<HomeProvider>().loadHomeData();
      }
    });
  }

  Future<void> _onRefresh() async {
    await context.read<HomeProvider>().loadHomeData();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final config = auth.provedorConfig;
    final appTheme = config?.theme ?? AppTheme();
    final homeProvider = context.watch<HomeProvider>();

    // Mock data fallback if API returned null values or is loading
    final mockConexao = ConexaoModel(
      online: true,
      status: 'Autenticado',
      pppoeUsuario: 'joao@netplus',
      ipAtual: '177.85.12.43',
      ultimaConexao: '14:32',
      downloadSpeed: 642.0,
      uploadSpeed: 618.0,
      planoVelocidade: '650 Mega',
    );

    final mockFatura = FaturaModel(
      id: '12345',
      valor: 105.00,
      vencimento: '2026-07-09',
      status: 'aberto',
      mesReferencia: 'Jul/2026',
      pixCopiaECola: '00020101021226830014br.gov.bcb.pix2561api.pix.provedor.com/qr/v2/cobv/73ea3716fd9d424b95f2425',
    );

    final activeConexao = homeProvider.conexao ?? mockConexao;
    final activeFatura = homeProvider.faturaAberta ?? mockFatura;

    final mockDevices = [
      {'name': 'Smart TV', 'type': 'tv', 'location': 'Sala'},
      {'name': 'iPhone 14', 'type': 'phone', 'location': 'Você'},
      {'name': 'Notebook', 'type': 'laptop', 'location': 'Escritório'},
      {'name': 'Alexa', 'type': 'speaker', 'location': 'Sala'},
    ];

    return Scaffold(
      backgroundColor: appTheme.backgroundColor,
      endDrawer: MenuLateralDrawer(theme: appTheme),
      body: homeProvider.isLoading && homeProvider.conexao == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              color: appTheme.primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // ── APP HEADER ──
                    AppHeader(
                      providerName: config?.nomeProvedor ?? 'NET+ Sua Internet',
                      userName: auth.usuario?.nome ?? 'Olá, João Silva',
                      notificationCount: 3,
                      theme: appTheme,
                      onNotificationTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nenhuma notificação nova no momento.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      onProfileTap: () {
                        Scaffold.of(context).openEndDrawer();
                      },
                    ),

                    // ── DARK HEADER OVERLAP CONTAINER ──
                    // Under the header we have a navy blue background that matches the header and wraps the status card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: appTheme.primaryColor,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: ConnectionStatusCard(
                        conexao: activeConexao,
                        theme: appTheme,
                        onDesbloquear: () async {
                          final success = await homeProvider.desbloquearConexao();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success
                                    ? 'Desbloqueio realizado!'
                                    : 'Erro ao desbloquear ou limite atingido'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                        onVerPlano: () {
                          // Action
                        },
                      ),
                    ),

                    // ── SCROLLABLE BODY CONTENT ──
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),

                          // ── Diagnose Connection ──
                          DiagnoseCard(
                            theme: appTheme,
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Iniciando diagnóstico completo da rede...'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),

                          // ── Invoice / Payment ──
                          FaturaCard(
                            fatura: activeFatura,
                            theme: appTheme,
                            onVerFaturas: () {
                              // We can send custom action or navigate using main shell index
                              // but since we are in tab, we just show message or redirect
                            },
                          ),
                          const SizedBox(height: 24),

                          // ── Quick Actions Grid ──
                          QuickActionsGrid(
                            theme: appTheme,
                            onActionTap: (actionId) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Ação rápida selecionada: $actionId'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // ── Connected Devices Section ──
                          ConnectedDevicesSection(
                            theme: appTheme,
                            totalDevices: 12,
                            devices: mockDevices,
                            onVerTodos: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Exibindo todos os 12 dispositivos da rede...'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),

                          // ── Referral Banner ──
                          ReferralBanner(
                            onIndicar: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Link de indicação gerado! Compartilhe com seus amigos.'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTvBannerCard(AppTheme theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            const Color(0xFF1E3A8A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TvScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tv_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'NET+ Play TV',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Assista canais de TV ao vivo grátis',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
