import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ConnectedDevicesSection extends StatelessWidget {
  final AppTheme theme;
  final int totalDevices;
  final List<Map<String, dynamic>> devices;
  final VoidCallback? onVerTodos;

  const ConnectedDevicesSection({
    super.key,
    required this.theme,
    required this.totalDevices,
    required this.devices,
    this.onVerTodos,
  });

  @override
  Widget build(BuildContext context) {
    final visibleDevices = devices.take(5).toList();
    final remaining = totalDevices - visibleDevices.length;

    return Column(
      children: [
        // ── Header ──
        Row(
          children: [
            // Green dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.successColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Dispositivos conectados',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            // Count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$totalDevices',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Spacer(),
            // "Ver todos" link
            InkWell(
              onTap: onVerTodos,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                child: Text(
                  'Ver todos',
                  style: TextStyle(
                    color: theme.secondaryColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Horizontal scroll list ──
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: visibleDevices.length + (remaining > 0 ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              // "+N Outros" chip
              if (index == visibleDevices.length) {
                return _buildOverflowChip(remaining);
              }
              final device = visibleDevices[index];
              return _buildDeviceChip(device);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceChip(Map<String, dynamic> device) {
    final String name = device['name'] ?? 'Dispositivo';
    final String type = device['type'] ?? 'other';
    final String location = device['location'] ?? '';

    return Container(
      width: 110,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _iconForType(type),
              color: theme.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              location,
              style: TextStyle(
                color: theme.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverflowChip(int count) {
    return Container(
      width: 88,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.devices_other_rounded,
              color: theme.primaryColor,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '+$count Outros',
            style: TextStyle(
              color: theme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'tv':
        return Icons.tv_rounded;
      case 'phone':
      case 'celular':
      case 'smartphone':
        return Icons.phone_android_rounded;
      case 'laptop':
      case 'notebook':
      case 'computer':
      case 'pc':
        return Icons.laptop_rounded;
      case 'speaker':
      case 'alexa':
      case 'echo':
        return Icons.speaker_rounded;
      case 'tablet':
      case 'ipad':
        return Icons.tablet_rounded;
      case 'camera':
        return Icons.videocam_rounded;
      case 'console':
      case 'game':
        return Icons.sports_esports_rounded;
      case 'printer':
        return Icons.print_rounded;
      default:
        return Icons.devices_rounded;
    }
  }
}
