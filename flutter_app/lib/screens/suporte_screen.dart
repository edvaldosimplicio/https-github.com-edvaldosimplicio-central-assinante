import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class SuporteScreen extends StatefulWidget {
  const SuporteScreen({super.key});

  @override
  State<SuporteScreen> createState() => _SuporteScreenState();
}

class _SuporteScreenState extends State<SuporteScreen> {
  final _mensagemController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _enviandoChamado = false;

  @override
  void dispose() {
    _mensagemController.dispose();
    super.dispose();
  }

  Future<void> _abrirWhatsapp(String numero) async {
    final cleanNumber = numero.replaceAll(RegExp(r'[^\d]'), '');
    final url = Uri.parse('https://wa.me/$cleanNumber?text=Ol%C3%A1%2C%20gostaria%20de%20suporte%20com%20minha%20conex%C3%A3o.');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
        );
      }
    }
  }

  Future<void> _enviarChamado(AppTheme theme) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _enviandoChamado = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate API send

    if (!mounted) return;
    setState(() => _enviandoChamado = false);
    _mensagemController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chamado aberto com sucesso! Nossa equipe entrará em contato.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final config = auth.provedorConfig;
    final appTheme = config?.theme ?? AppTheme();
    final whatsappNumber = config?.suporteWhatsapp ?? '5511999999999';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suporte ao Cliente',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: appTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── WhatsApp Direct Card ──
            Card(
              elevation: 0,
              color: const Color(0xFF25D366).withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF25D366), width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF25D366),
                          child: Icon(Icons.chat_bubble_rounded, color: Colors.white),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Falar no WhatsApp',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E7E34),
                                ),
                              ),
                              Text(
                                'Atendimento rápido e automatizado',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _abrirWhatsapp(whatsappNumber),
                        icon: const Icon(Icons.chat_rounded, size: 20),
                        label: const Text('Iniciar Conversa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Open Ticket Form ──
            _buildSectionHeader('Abrir um Chamado', appTheme),
            const SizedBox(height: 10),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Descreva o problema ou dúvida',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _mensagemController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Digite aqui os detalhes...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Por favor, escreva uma mensagem'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _enviandoChamado
                              ? null
                              : () => _enviarChamado(appTheme),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appTheme.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: _enviandoChamado
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Enviar Mensagem'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── FAQ Section ──
            _buildSectionHeader('Perguntas Frequentes', appTheme),
            const SizedBox(height: 10),
            _buildFaqItem(
              'Como alterar a senha do meu Wi-Fi?',
              'Você pode alterar a senha do seu Wi-Fi diretamente na aba "Internet" deste aplicativo, preenchendo o formulário de alteração rápida e salvando.',
            ),
            _buildFaqItem(
              'Minha conexão está lenta, o que fazer?',
              'Primeiro, experimente reiniciar seu roteador da tomada, aguarde 30 segundos e ligue-o novamente. Se o problema persistir, use o botão "Diagnosticar Conexão" na tela inicial.',
            ),
            _buildFaqItem(
              'O que é o Desbloqueio em Confiança?',
              'Se você possui alguma fatura em atraso e sua conexão foi bloqueada, é possível liberá-la temporariamente por 3 dias através do botão "Desbloqueio em Confiança" na aba Início.',
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, AppTheme theme) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: theme.primaryColor,
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedAlignment: Alignment.topLeft,
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
