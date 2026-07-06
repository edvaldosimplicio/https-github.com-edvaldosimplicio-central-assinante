import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'tv_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.usuario;
    final config = auth.provedorConfig;
    final appTheme = config?.theme ?? AppTheme();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: appTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── User Avatar + Name ──
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: appTheme.primaryColor.withValues(alpha: 0.1),
                    child: Text(
                      user?.iniciais ?? 'U',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: appTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.nome ?? 'Usuário',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.cpfMascarado ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Plan Info Card ──
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Plano Atual',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: appTheme.successColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'ATIVO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: appTheme.successColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      user?.plano ?? 'Plano Contratado 650 Mega',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: appTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tecnologia: Fibra Óptica FTTH',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Menu List ──
            _buildMenuItem(Icons.person_outline_rounded, 'Dados Pessoais', 'Visualize seus dados de cadastro', appTheme),
            _buildMenuItem(Icons.lock_outline_rounded, 'Alterar Senha', 'Mude a senha de acesso ao app', appTheme),
            _buildMenuItem(Icons.notifications_none_rounded, 'Notificações', 'Gerencie seus alertas e avisos', appTheme),
            _buildMenuItem(Icons.info_outline_rounded, 'Sobre o Provedor', config?.nomeProvedor ?? 'Detalhes da empresa', appTheme),
            _buildMenuItem(Icons.description_outlined, 'Termos e Contratos', 'Acesse seus contratos digitais', appTheme),
            _buildMenuItem(
              Icons.tv_rounded,
              'Play TV',
              'Assista canais de TV ao vivo',
              appTheme,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TvScreen()),
                );
              },
            ),

            const SizedBox(height: 24),

            // ── Logout Button ──
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sair da Conta'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appTheme.errorColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── App Version ──
            const Text(
              'Versão 1.0.0 (Build 1)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String subtitle, AppTheme theme, {VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withValues(alpha: 0.05),
          child: Icon(icon, color: theme.primaryColor),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
