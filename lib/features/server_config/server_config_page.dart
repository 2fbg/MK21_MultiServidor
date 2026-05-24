import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../home/home_page.dart';
import '../../models/server_config.dart';
import '../../models/server_profile.dart';
import '../../services/server_config_service.dart';

class ServerConfigPage extends StatefulWidget {
  const ServerConfigPage({super.key});

  @override
  State<ServerConfigPage> createState() => _ServerConfigPageState();
}

class _ServerConfigPageState extends State<ServerConfigPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _manualUrlController = TextEditingController();

  ServerProfile _selectedProfile = ServerProfiles.all.first;
  bool _manualMode = false;
  bool _obscurePassword = true;
  bool _saving = false;

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

  String? _credentialValidator(String? value) {
    final String? requiredError = _required(value);
    if (requiredError != null) return requiredError;

    if (value!.trim().length > 15) {
      return 'Máximo de 15 caracteres';
    }

    return null;
  }

  String? _urlValidator(String? value) {
    final String? requiredError = _required(value);
    if (requiredError != null) return requiredError;

    final String text = value!.trim();
    final Uri? uri = Uri.tryParse(text);

    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'URL inválida';
    }

    if (!text.startsWith('http://') && !text.startsWith('https://')) {
      return 'A URL precisa começar com http:// ou https://';
    }

    return null;
  }

  String _buildFinalUrl() {
    if (_manualMode) {
      return _manualUrlController.text.trim();
    }

    return _selectedProfile.buildM3uUrl(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  Future<void> _saveAndEnter() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _saving = true);

    try {
      final ServerConfig config = ServerConfig(
        serverName: _manualMode ? 'Lista Manual' : _selectedProfile.name,
        playlistUrl: _buildFinalUrl(),
        isManualUrl: _manualMode,
        profileId: _manualMode ? null : _selectedProfile.id,
        username: _manualMode ? null : _usernameController.text.trim(),
        password: _manualMode ? null : _passwordController.text.trim(),
        userAgent: 'Mozilla/5.0',
      );

      await const ServerConfigService().save(config);

      if (!mounted) return;

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => const HomePage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Future<void> _previewUrl() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final String url = _buildFinalUrl();

    await showDialog<void>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('URL gerada'),
          content: SelectableText(url),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.72),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.18),
        ),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFE50914),
          width: 1.6,
        ),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFE50914),
          width: 1.2,
        ),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xFFE50914),
          width: 1.6,
        ),
      ),
      suffixIcon: suffixIcon,
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
            colors: [
              Color(0xFF182B4F),
              Color(0xFF090D17),
              Color(0xFF05070D),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 860),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Configuração do servidor',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'As credenciais ficam salvas com segurança e podem ser reutilizadas entre servidores.',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.65),
                                ),
                              ),
                              const SizedBox(height: 28),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<ServerProfile>(
                                      initialValue: _selectedProfile,
                                      dropdownColor: const Color(0xFF111827),
                                      decoration: _inputDecoration(
                                        label: 'Servidor',
                                      ),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      items: ServerProfiles.all.map((profile) {
                                        return DropdownMenuItem<ServerProfile>(
                                          value: profile,
                                          child: Text(profile.name),
                                        );
                                      }).toList(),
                                      onChanged: (ServerProfile? value) {
                                        if (value == null) return;
                                        setState(() => _selectedProfile = value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Lista manual',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Switch(
                                        value: _manualMode,
                                        onChanged: (bool value) {
                                          setState(() => _manualMode = value);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              if (!_manualMode) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _usernameController,
                                        validator: _credentialValidator,
                                        inputFormatters: const [
                                          LengthLimitingTextInputFormatter(15),
                                        ],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: _inputDecoration(
                                          label: 'Usuário',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _passwordController,
                                        validator: _credentialValidator,
                                        obscureText: _obscurePassword,
                                        inputFormatters: const [
                                          LengthLimitingTextInputFormatter(15),
                                        ],
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                        decoration: _inputDecoration(
                                          label: 'Senha',
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ] else ...[
                                TextFormField(
                                  controller: _manualUrlController,
                                  validator: _urlValidator,
                                  minLines: 2,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  decoration: _inputDecoration(
                                    label: 'URL M3U',
                                  ),
                                ),
                              ],
                              const SizedBox(height: 28),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _saving ? null : _previewUrl,
                                      icon: const Icon(Icons.link_outlined),
                                      label: const Text('Visualizar URL'),
                                      style: OutlinedButton.styleFrom(
                                        minimumSize: const Size.fromHeight(52),
                                        side: BorderSide(
                                          color: Colors.white.withValues(
                                            alpha: 0.18,
                                          ),
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed:
                                          _saving ? null : _saveAndEnter,
                                      icon: _saving
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(Icons.save_outlined),
                                      label: Text(
                                        _saving
                                            ? 'Salvando...'
                                            : 'Salvar e entrar',
                                      ),
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size.fromHeight(52),
                                        backgroundColor:
                                            const Color(0xFFE50914),
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
