class CanalModel {
  final String name;
  final String logo;
  final String category;
  final String url;

  CanalModel({
    required this.name,
    required this.logo,
    required this.category,
    required this.url,
  });

  factory CanalModel.fromJson(Map<String, dynamic> json) {
    return CanalModel(
      name: json['name'] ?? 'Canal Sem Nome',
      logo: json['logo'] ?? '',
      category: json['category'] ?? 'Geral',
      url: json['url'] ?? '',
    );
  }
}
