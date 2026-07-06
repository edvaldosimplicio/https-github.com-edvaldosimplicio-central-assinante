import 'package:flutter/material.dart';
import '../models/conexao_model.dart';
import '../theme/app_theme.dart';

class ConnectionStatusCard extends StatelessWidget {
  final ConexaoModel conexao;
  final AppTheme theme;
  final VoidCallback? onDesbloquear;
  final VoidCallback? onVerPlano;

  const ConnectionStatusCard({
    super.key,
    required this.conexao,
    required this.theme,
    this.onDesbloquear,
    this.onVerPlano,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: conexao.online
              ? [
                  theme.primaryColor,
                  const Color(0xFF243656),
                ]
              : [
                  const Color(0xFF7F1D1D),
                  const Color(0xFF991B1B),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Top section: status + plan ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: icon + status text
                Expanded(child: _buildLeftSection()),
                const SizedBox(width: 16),
                // Right side: plan info
                _buildRightSection(),
              ],
            ),
          ),

          // ── Divider ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Divider(
              color: Colors.white.withValues(alpha: 0.12),
              height: 1,
            ),
          ),

          // ── Bottom section: speeds ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
            child: _buildSpeedsSection(),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftSection() {
    final isOnline = conexao.online;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // WiFi icon with glow
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isOnline
                ? theme.successColor.withValues(alpha: 0.2)
                : theme.errorColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: isOnline
                    ? theme.successColor.withValues(alpha: 0.3)
                    : theme.errorColor.withValues(alpha: 0.3),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            isOnline ? Icons.wifi : Icons.wifi_off,
            color: isOnline ? theme.successColor : theme.errorColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 16),

        // Online/Offline badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isOnline
                ? theme.successColor.withValues(alpha: 0.15)
                : theme.errorColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? theme.successColor : theme.errorColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isOnline ? 'ONLINE' : 'OFFLINE',
                style: TextStyle(
                  color: isOnline ? theme.successColor : theme.errorColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Status message
        Text(
          isOnline
              ? 'Sua internet está funcionando bem!'
              : 'Sua internet está com problemas',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),

        // Connection time / subtitle
        Text(
          isOnline
              ? 'Conexão estável desde ${_formatarHora(conexao.ultimaConexao)}'
              : 'Verifique seu equipamento ou desbloqueie',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),

        // Unlock button when offline
        if (!isOnline && onDesbloquear != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: onDesbloquear,
              icon: const Icon(Icons.lock_open, size: 18),
              label: const Text('Desbloquear'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRightSection() {
    if (!conexao.online) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Plan label
        Text(
          'PLANO CONTRATADO',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),

        // Plan speed
        Text(
          conexao.planoVelocidade ?? '—',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.1,
          ),
        ),
        if (conexao.planoNome != null) ...[
          const SizedBox(height: 2),
          Text(
            conexao.planoNome!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
        const SizedBox(height: 12),

        // "Ver meu plano" button
        SizedBox(
          height: 34,
          child: TextButton(
            onPressed: onVerPlano,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF00897B).withValues(alpha: 0.2),
              foregroundColor: const Color(0xFF4DB6AC),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Ver meu plano'),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedsSection() {
    return Row(
      children: [
        // Download speed
        Expanded(
          child: _buildSpeedIndicator(
            icon: Icons.arrow_downward_rounded,
            label: 'Download',
            speed: conexao.downloadSpeed,
          ),
        ),
        // Vertical divider
        Container(
          width: 1,
          height: 44,
          color: Colors.white.withValues(alpha: 0.12),
        ),
        // Upload speed
        Expanded(
          child: _buildSpeedIndicator(
            icon: Icons.arrow_upward_rounded,
            label: 'Upload',
            speed: conexao.uploadSpeed,
          ),
        ),
      ],
    );
  }

  Widget _buildSpeedIndicator({
    required IconData icon,
    required String label,
    required double? speed,
  }) {
    final speedColor =
        conexao.online ? theme.successColor : theme.errorColor;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: speedColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: speedColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  speed != null ? speed.toStringAsFixed(0) : '—',
                  style: TextStyle(
                    color: speedColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 3),
                Text(
                  'Mbps',
                  style: TextStyle(
                    color: speedColor.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _formatarHora(String? dataHora) {
    if (dataHora == null || dataHora.isEmpty) return '--:--';
    try {
      final dt = DateTime.parse(dataHora);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      // Try to extract HH:mm from common formats
      if (dataHora.contains(':')) {
        final parts = dataHora.split(' ');
        for (final part in parts) {
          if (part.contains(':')) return part.substring(0, 5);
        }
      }
      return dataHora;
    }
  }
}
