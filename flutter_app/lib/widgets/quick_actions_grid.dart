import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class _QuickAction {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _QuickAction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class QuickActionsGrid extends StatelessWidget {
  final AppTheme theme;
  final Function(String action)? onActionTap;

  const QuickActionsGrid({
    super.key,
    required this.theme,
    this.onActionTap,
  });

  static const List<_QuickAction> _actions = [
    _QuickAction(
      id: 'wifi',
      title: 'Gerenciar Wi-Fi',
      subtitle: 'Nome, senha e configurações',
      icon: Icons.wifi,
      color: Color(0xFF2E7D32),
    ),
    _QuickAction(
      id: 'cameras',
      title: 'Minhas câmeras',
      subtitle: 'Acesse suas câmeras ao vivo',
      icon: Icons.videocam_rounded,
      color: Color(0xFF1976D2),
    ),
    _QuickAction(
      id: 'speed_test',
      title: 'Medir minha internet',
      subtitle: 'Abra o teste de velocidade',
      icon: Icons.speed_rounded,
      color: Color(0xFF00897B),
    ),
    _QuickAction(
      id: 'financeiro',
      title: 'Financeiro',
      subtitle: 'Faturas, pagamentos e comprovantes',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF2E7D32),
    ),
    _QuickAction(
      id: 'suporte',
      title: 'Falar com o provedor',
      subtitle: 'WhatsApp, chat ou telefone',
      icon: Icons.support_agent_rounded,
      color: Color(0xFF1976D2),
    ),
    _QuickAction(
      id: 'plano',
      title: 'Meu plano',
      subtitle: 'Detalhes do seu plano e contrato',
      icon: Icons.person_rounded,
      color: Color(0xFF42A5F5),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Header ──
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ações rápidas',
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              InkWell(
                onTap: () => onActionTap?.call('personalizar'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: theme.textSecondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Personalizar',
                        style: TextStyle(
                          color: theme.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Grid ──
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.55,
          ),
          itemBuilder: (context, index) {
            final action = _actions[index];
            return _ActionCard(
              action: action,
              theme: theme,
              onTap: () => onActionTap?.call(action.id),
            );
          },
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final _QuickAction action;
  final AppTheme theme;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.action,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: action.color.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: action.color.withValues(alpha: 0.12),
                width: 1.5,
              ),
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  action.color.withValues(alpha: 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon row with chevron
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            action.color,
                            action.color.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: action.color.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        action.icon,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: action.color.withValues(alpha: 0.4),
                      size: 14,
                    ),
                  ],
                ),
                const Spacer(),

                // Title
                Text(
                  action.title,
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),

                // Subtitle
                Text(
                  action.subtitle,
                  style: TextStyle(
                    color: theme.textSecondary.withValues(alpha: 0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
