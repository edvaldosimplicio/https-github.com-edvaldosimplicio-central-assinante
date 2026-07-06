class FaturaModel {
  final String id;
  final double valor;
  final String vencimento;
  final String? pagamento;
  final String status;
  final String? mesReferencia;
  final String? linkBoleto;
  final String? pixCopiaECola;

  FaturaModel({
    required this.id,
    required this.valor,
    required this.vencimento,
    this.pagamento,
    required this.status,
    this.mesReferencia,
    this.linkBoleto,
    this.pixCopiaECola,
  });

  factory FaturaModel.fromJson(Map<String, dynamic> json) {
    return FaturaModel(
      id: json['id']?.toString() ?? '',
      valor: (json['valor'] ?? 0).toDouble(),
      vencimento: json['vencimento'] ?? '',
      pagamento: json['pagamento'],
      status: json['status'] ?? '',
      mesReferencia: json['mesReferencia'],
      linkBoleto: json['linkBoleto'],
      pixCopiaECola: json['pixCopiaECola'],
    );
  }

  bool get estaAberta => status == 'aberto' || status == 'aberta';
  bool get estaPaga => status == 'pago' || status == 'paga';
}
