import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../screens/tv_screen.dart';

class MenuLateralDrawer extends StatelessWidget {
  final AppTheme theme;

  const MenuLateralDrawer({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final config = auth.provedorConfig;
    final user = auth.usuario;

    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // ── Header (Purple/Navy matching config) ──
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 24, 20, 24),
            decoration: BoxDecoration(
              color: theme.primaryColor,
            ),
            child: Column(
              children: [
                // Circular Logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: ClipOval(
                    child: config?.logoUrl != null && config!.logoUrl.isNotEmpty
                        ? Image.network(
                            config.logoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => _buildLogoFallback(config.nomeProvedor),
                          )
                        : _buildLogoFallback(config?.nomeProvedor ?? 'NET+'),
                  ),
                ),
                const SizedBox(height: 16),
                // Facebook / Social Icon
                Icon(
                  Icons.facebook,
                  color: Colors.white.withValues(alpha: 0.9),
                  size: 24,
                ),
              ],
            ),
          ),

          // ── Menu Options List ──
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerItem(
                  context,
                  icon: Icons.handshake_outlined,
                  title: 'Prometer Pagamento',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sua promessa de pagamento foi registrada! Conexão liberada.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.support_agent_rounded,
                  title: 'Suporte Técnico',
                  onTap: () {
                    Navigator.pop(context);
                    // Standard way to switch tab is via parent shell, for now open snackbar or push screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Acesse a aba Suporte na barra inferior.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.speed_rounded,
                  title: 'Teste de Velocidade',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Acesse a aba Internet na barra inferior para testar.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.warning_amber_rounded,
                  title: 'DownDetector',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sua região está com conexão estável. Nenhuma falha detectada.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.wifi_rounded,
                  title: 'Minha Internet',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Acesse a aba Internet na barra inferior.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.bar_chart_rounded,
                  title: 'Gráfico de Consumo',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gráfico de consumo será gerado após 30 dias de uso da internet.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Seus Contratos',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Contrato de prestação de serviço ativo (Fibra Óptica).'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.star_outline_rounded,
                  title: 'Avalie nosso App',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Obrigado pela sua avaliação de 5 estrelas! ⭐⭐⭐⭐⭐'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                
                const Divider(height: 24, indent: 20, endIndent: 20),

                // ── PLAY TV ──
                _buildDrawerItem(
                  context,
                  icon: Icons.tv_rounded,
                  title: 'Play TV',
                  titleColor: theme.primaryColor,
                  iconColor: theme.primaryColor,
                  isBold: true,
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TvScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoFallback(String name) {
    return Center(
      child: Text(
        name.substring(0, name.length > 3 ? 3 : name.length).toUpperCase(),
        style: TextStyle(
          color: theme.primaryColor,
          fontWeight: FontWeight.w900,
          fontSize: 22,
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    bool isBold = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.black54,
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? Colors.black87,
          fontSize: 14,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.black26,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
