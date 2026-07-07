import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_config.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../services/iptv_service.dart';
import '../models/canal_model.dart';
import '../theme/app_theme.dart';
import 'player_screen.dart';

class TvScreen extends StatefulWidget {
  const TvScreen({super.key});

  @override
  State<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends State<TvScreen> with SingleTickerProviderStateMixin {
  List<CanalModel> _canais = [];
  List<CanalModel> _filteredCanais = [];
  List<String> _categorias = ['Todos'];
  String _selectedCategoria = 'Todos';
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCanais();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCanais() async {
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      final api = ApiService(
        baseUrl: AppConfig.defaultBaseUrl,
        token: auth.token,
        provedorId: auth.provedorConfig?.slug,
      );
      final service = IptvService(api);
      final list = await service.getCanais();

      // Extract unique categories
      final cats = list.map((c) => c.category).toSet().toList();
      cats.sort();

      if (mounted) {
        setState(() {
          _canais = list;
          _filteredCanais = list;
          _categorias = ['Todos', ...cats];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar canais: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterCanais(String query) {
    setState(() {
      _filteredCanais = _canais.where((c) {
        final matchesQuery = c.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategoria == 'Todos' || c.category == _selectedCategoria;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final appTheme = auth.provedorConfig?.theme ?? AppTheme();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NET+ Play TV',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: appTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // ── Search Bar ──
                Container(
                  color: appTheme.primaryColor,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterCanais,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Pesquisar canais...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                  ),
                ),

                // ── Categories Row ──
                Container(
                  height: 48,
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _categorias.length,
                    itemBuilder: (context, index) {
                      final cat = _categorias[index];
                      final isSelected = _selectedCategoria == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          selectedColor: appTheme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategoria = cat;
                                _filterCanais(_searchController.text);
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),

                // ── Channels Grid ──
                Expanded(
                  child: _filteredCanais.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhum canal encontrado',
                            style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(20),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.3,
                          ),
                          itemCount: _filteredCanais.length,
                          itemBuilder: (context, index) {
                            final canal = _filteredCanais[index];
                            return _buildChannelCard(canal, appTheme);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildChannelCard(CanalModel canal, AppTheme theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlayerScreen(
                channelName: canal.name,
                streamUrl: canal.url,
                theme: theme,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo image
              Expanded(
                child: canal.logo.isNotEmpty
                    ? Image.network(
                        canal.logo,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.tv_rounded, size: 40, color: theme.primaryColor.withValues(alpha: 0.5));
                        },
                      )
                    : Icon(Icons.tv_rounded, size: 40, color: theme.primaryColor.withValues(alpha: 0.5)),
              ),
              const SizedBox(height: 8),
              Text(
                canal.name,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                canal.category,
                style: TextStyle(
                  fontSize: 10,
                  color: theme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
