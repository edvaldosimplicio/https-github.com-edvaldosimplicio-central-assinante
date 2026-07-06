import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DiagnoseCard extends StatelessWidget {
  final AppTheme theme;
  final VoidCallback? onTap;

  const DiagnoseCard({
    super.key,
    required this.theme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.secondaryColor.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Green shield icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: theme.successColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnosticar minha conexão',
                      style: TextStyle(
                        color: theme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Verifique o status completo da sua internet',
                      style: TextStyle(
                        color: theme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Chevron
              Icon(
                Icons.chevron_right_rounded,
                color: theme.textSecondary.withValues(alpha: 0.5),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
