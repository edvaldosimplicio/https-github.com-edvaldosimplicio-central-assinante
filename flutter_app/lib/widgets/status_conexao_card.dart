import 'package:flutter/material.dart';
import '../models/conexao_model.dart';
import '../theme/app_theme.dart';

class StatusConexaoCard extends StatelessWidget {
  final ConexaoModel conexao;
  final AppTheme theme;
  final VoidCallback? onDesbloquear;

  const StatusConexaoCard({
    super.key,
    required this.conexao,
    required this.theme,
    this.onDesbloquear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: conexao.online
                      ? theme.successColor
                      : theme.warningColor,
                  boxShadow: [
                    BoxShadow(
                      color: (conexao.online
                              ? theme.successColor
                              : theme.warningColor)
                          .withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                conexao.online ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (conexao.online
                          ? theme.successColor
                          : theme.warningColor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  conexao.online ? 'Autenticado' : 'Desconectado',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: conexao.online
                        ? theme.successColor
                        : theme.warningColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _infoItem(Icons.wifi, 'PPPoE', conexao.pppoeUsuario ?? '-'),
              const SizedBox(width: 24),
              _infoItem(Icons.language, 'IP', conexao.ipAtual ?? '-'),
            ],
          ),
          if (!conexao.online && onDesbloquear != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDesbloquear,
                icon: const Icon(Icons.lock_open, size: 20),
                label: const Text('Desbloqueio em Confiança'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.warningColor,
                  side: BorderSide(color: theme.warningColor.withValues(alpha: 0.4)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.textSecondary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: theme.textSecondary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
