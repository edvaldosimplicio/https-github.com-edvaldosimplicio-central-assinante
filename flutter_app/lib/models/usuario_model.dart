class UsuarioModel {
  final String nome;
  final String cpfCnpj;
  final String? email;
  final String? telefone;
  final String? endereco;
  final String? plano;
  final String? codigoCliente;

  UsuarioModel({
    required this.nome,
    required this.cpfCnpj,
    this.email,
    this.telefone,
    this.endereco,
    this.plano,
    this.codigoCliente,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      nome: json['nome'] ?? '',
      cpfCnpj: json['cpfCnpj'] ?? json['cpf_cnpj'] ?? '',
      email: json['email'],
      telefone: json['telefone'],
      endereco: json['endereco'],
      plano: json['plano'],
      codigoCliente: json['codigoCliente']?.toString(),
    );
  }

  String get iniciais {
    final parts = nome.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return nome.isNotEmpty ? nome[0].toUpperCase() : 'U';
  }

  String get primeiroNome {
    return nome.split(' ').first;
  }

  String get cpfMascarado {
    if (cpfCnpj.length == 11) {
      return '***.***.${cpfCnpj.substring(6, 9)}-${cpfCnpj.substring(9)}';
    } else if (cpfCnpj.length == 14) {
      return '**.***.${cpfCnpj.substring(5, 8)}/****-${cpfCnpj.substring(12)}';
    }
    return cpfCnpj;
  }
}
