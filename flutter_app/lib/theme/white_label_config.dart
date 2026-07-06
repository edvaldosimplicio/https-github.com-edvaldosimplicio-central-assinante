import 'package:flutter/material.dart';
import 'app_theme.dart';

class WhiteLabelConfig {
  final String nomeProvedor;
  final String slug;
  final String logoUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final String? suporteWhatsapp;
  final String? m3uUrl;

  WhiteLabelConfig({
    required this.nomeProvedor,
    required this.slug,
    this.logoUrl = '',
    this.primaryColor = const Color(0xFF1A2744),
    this.secondaryColor = const Color(0xFF2E7D32),
    this.suporteWhatsapp,
    this.m3uUrl,
  });

  AppTheme get theme => AppTheme(
        primaryColor: primaryColor,
        secondaryColor: secondaryColor,
      );

  factory WhiteLabelConfig.fromJson(Map<String, dynamic> json) {
    return WhiteLabelConfig(
      nomeProvedor: json['nome'] ?? '',
      slug: json['slug'] ?? '',
      logoUrl: json['logo_url'] ?? '',
      primaryColor: _parseColor(json['primary_color'], const Color(0xFF1A2744)),
      secondaryColor:
          _parseColor(json['secondary_color'], const Color(0xFF2E7D32)),
      suporteWhatsapp: json['suporte_whatsapp'],
      m3uUrl: json['m3u_url'],
    );
  }

  static Color _parseColor(String? hex, Color fallback) {
    if (hex == null) return fallback;
    final color = int.tryParse(hex.replaceFirst('#', '0xFF'));
    return color != null ? Color(color) : fallback;
  }
}
