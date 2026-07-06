class ConexaoModel {
  final bool online;
  final String status;
  final String? pppoeUsuario;
  final String? ipAtual;
  final String? ultimaConexao;
  final double? downloadSpeed;
  final double? uploadSpeed;
  final String? planoNome;
  final String? planoVelocidade;

  ConexaoModel({
    required this.online,
    required this.status,
    this.pppoeUsuario,
    this.ipAtual,
    this.ultimaConexao,
    this.downloadSpeed,
    this.uploadSpeed,
    this.planoNome,
    this.planoVelocidade,
  });

  factory ConexaoModel.fromJson(Map<String, dynamic> json) {
    return ConexaoModel(
      online: json['online'] ?? false,
      status: json['status'] ?? 'indisponivel',
      pppoeUsuario: json['pppoeUsuario'],
      ipAtual: json['ipAtual'],
      ultimaConexao: json['ultimaConexao'],
      downloadSpeed: (json['downloadSpeed'] as num?)?.toDouble(),
      uploadSpeed: (json['uploadSpeed'] as num?)?.toDouble(),
      planoNome: json['planoNome'],
      planoVelocidade: json['planoVelocidade'],
    );
  }
}
