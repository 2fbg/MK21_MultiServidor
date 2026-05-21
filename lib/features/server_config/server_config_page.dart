import 'package:flutter/material.dart';

import '../../features/home/home_page.dart';
import '../../models/server_config.dart';
import '../../models/server_profile.dart';
import '../../services/server_config_service.dart';

class ServerConfigPage extends StatefulWidget {
  const ServerConfigPage({super.key});

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _manualUrlController = TextEditingController();

  ServerProfile _selectedProfile = ServerProfiles.all.first;
  bool _manualMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _manualUrlController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  String? _url(String? value) {
    final required = _required(value);
    if (required != null) return required;

    final text = value!.trim();

    if (!text.startsWith('http://') && !text.startsWith('https://')) {
      return 'URL precisa começar com http:// ou https://';
    }

    if (!text.contains('username=') || !text.contains('password=')) {
      return 'A URL deve conter username= e password=';
    }

    return null;
  }

  String _cleanUrl(String url) {
    return url
        .replaceAll('&amp;', '&')
        .replaceAll(' ', '')
        .trim();
  }

  String _buildFinalUrl() {
    if (_manualMode) {
      return _cleanUrl(_manualUrlController.text);
    }

    return _selectedProfile.buildM3uUrl(
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _saveAndEnter() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final playlistUrl = _buildFinalUrl();

    final config = ServerConfig(
      serverName: _manualMode ? 'Lista Manual' : _selectedProfile.name,
      playlistUrl: playlistUrl,
      isManualUrl: _manualMode,
      profileId: _manualMode ? null : _selectedProfile.id,
      username: _manualMode ? null : _usernameController.text.trim(),
      password: _manualMode ? null : _passwordController.text.trim(),

      /// ✅ User-Agent oculto mas funcional
      userAgent: 'Mozilla/5.0',
    );

    await const ServerConfigService().save(config);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  void _previewUrl() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final url = _buildFinalUrl();

    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('URL gerada'),
        content: SelectableText(url),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.15,
            colors: [Color(0xFF182B4F), Color(0xFF090D17), Color(0xFF05070D)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SwitchListTile(
              value: _manualMode,
              onChanged: (v) => setState(() => _manualMode = v),
              title: const Text('Lista manual'),
            ),

            const SizedBox(height: 10),

            if (!_manualMode) ...[
              DropdownButtonFormField<ServerProfile>(
                value: _selectedProfile,
                items: ServerProfiles.all.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p.name),
                  );
                }).toList(),
                onChanged: (p) => setState(() => _selectedProfile = p!),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _usernameController,
                validator: _required,
                decoration: const InputDecoration(labelText: 'Usuário'),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _passwordController,
                validator: _required,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
            ] else ...[
              TextFormField(
                controller: _manualUrlController,
                validator: _url,
                decoration: const InputDecoration(labelText: 'URL M3U'),
              ),
            ],

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previewUrl,
                    child: const Text('Visualizar URL'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveAndEnter,
                    child: const Text('Salvar e entrar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
