class DispositivoModel {
  final String nome;
  final String tipo; // 'tv', 'phone', 'laptop', 'speaker', 'tablet', 'other'
  final String? localizacao;
  final String? ip;
  final bool online;

  DispositivoModel({
    required this.nome,
    required this.tipo,
    this.localizacao,
    this.ip,
    this.online = true,
  });

  factory DispositivoModel.fromJson(Map<String, dynamic> json) {
    return DispositivoModel(
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? 'other',
      localizacao: json['localizacao'],
      ip: json['ip'],
      online: json['online'] ?? true,
    );
  }
}
