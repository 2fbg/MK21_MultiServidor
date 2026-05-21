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
  final _userAgentController = TextEditingController(
    text: 'MK21-MultiServidor/1.0',
  );

  ServerProfile _selectedProfile = ServerProfiles.all.first;
  bool _manualMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _manualUrlController.dispose();
    _userAgentController.dispose();
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
    if (required != null) {
      return required;
    }

    final text = value!.trim();

    if (!text.startsWith('http://') && !text.startsWith('https://')) {
      return 'Informe uma URL começando com http:// ou https://';
    }

    if (!text.contains('username=') || !text.contains('password=')) {
      return 'A lista manual precisa conter username= e password= no link';
    }

    return null;
  }

  String _buildFinalUrl() {
    if (_manualMode) {
      return _manualUrlController.text.trim();
    }

    return _selectedProfile.buildM3uUrl(
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  Future<void> _saveAndEnter() async {
    final valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    final playlistUrl = _buildFinalUrl();

    final config = ServerConfig(
      serverName: _manualMode ? 'Lista Manual' : _selectedProfile.name,
      playlistUrl: playlistUrl,
      isManualUrl: _manualMode,
      profileId: _manualMode ? null : _selectedProfile.id,
      username: _manualMode ? null : _usernameController.text.trim(),
      password: _manualMode ? null : _passwordController.text.trim(),
      userAgent: _userAgentController.text.trim().isEmpty
          ? 'MK21-MultiServidor/1.0'
          : _userAgentController.text.trim(),
    );

    await const ServerConfigService().save(config);

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Servidor salvo com sucesso.'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  void _previewUrl() {
    final valid = _formKey.currentState?.validate() ?? false;

    if (!valid) {
      return;
    }

    final url = _buildFinalUrl();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('URL M3U gerada'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.15,
            colors: [Color(0xFF182B4F), Color(0xFF090D17), Color(0xFF05070D)],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 820),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 36),
                      child: _ConfigCard(
                        formKey: _formKey,
                        manualMode: _manualMode,
                        selectedProfile: _selectedProfile,
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        manualUrlController: _manualUrlController,
                        userAgentController: _userAgentController,
                        obscurePassword: _obscurePassword,
                        onManualModeChanged: (value) {
                          setState(() => _manualMode = value);
                        },
                        onProfileChanged: (profile) {
                          if (profile != null) {
                            setState(() => _selectedProfile = profile);
                          }
                        },
                        onTogglePassword: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        requiredValidator: _required,
                        urlValidator: _url,
                        onPreview: _previewUrl,
                        onSave: _saveAndEnter,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 22, 28, 18),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF00A3FF).withOpacity(0.22),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF00A3FF).withOpacity(0.65),
              ),
            ),
            child: const Icon(
              Icons.dns_rounded,
              color: Color(0xFF00A3FF),
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configurar servidor',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Escolha um servidor ou cole uma lista M3U manual',
                  style: TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({
    required this.formKey,
    required this.manualMode,
    required this.selectedProfile,
    required this.usernameController,
    required this.passwordController,
    required this.manualUrlController,
    required this.userAgentController,
    required this.obscurePassword,
    required this.onManualModeChanged,
    required this.onProfileChanged,
    required this.onTogglePassword,
    required this.requiredValidator,
    required this.urlValidator,
    required this.onPreview,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final bool manualMode;
  final ServerProfile selectedProfile;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController manualUrlController;
  final TextEditingController userAgentController;
  final bool obscurePassword;
  final ValueChanged<bool> onManualModeChanged;
  final ValueChanged<ServerProfile?> onProfileChanged;
  final VoidCallback onTogglePassword;
  final String? Function(String?) requiredValidator;
  final String? Function(String?) urlValidator;
  final VoidCallback onPreview;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.10)),
      ),
      child: Form(
        key: formKey,
        child: Column(
          children: [
            SwitchListTile(
              value: manualMode,
              onChanged: onManualModeChanged,
              title: const Text(
                'Usar lista manual',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Ative para colar uma URL M3U completa com usuário e senha no link.',
              ),
            ),
            const SizedBox(height: 14),
            if (!manualMode) ...[
              DropdownButtonFormField<ServerProfile>(
                value: selectedProfile,
                decoration: InputDecoration(
                  labelText: 'Servidor',
                  prefixIcon: const Icon(Icons.dns),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                items: ServerProfiles.all.map((profile) {
                  return DropdownMenuItem(
                    value: profile,
                    child: Text(profile.name),
                  );
                }).toList(),
                onChanged: onProfileChanged,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _InputField(
                      controller: usernameController,
                      label: 'Usuário',
                      icon: Icons.person,
                      validator: requiredValidator,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _InputField(
                      controller: passwordController,
                      label: 'Senha',
                      icon: Icons.lock,
                      validator: requiredValidator,
                      obscureText: obscurePassword,
                      suffixIcon: IconButton(
                        onPressed: onTogglePassword,
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              _InputField(
                controller: manualUrlController,
                label: 'URL M3U manual',
                icon: Icons.link,
                validator: urlValidator,
                keyboardType: TextInputType.url,
              ),
            ],
            const SizedBox(height: 14),
            _InputField(
              controller: userAgentController,
              label: 'User-Agent',
              icon: Icons.http,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPreview,
                    icon: const Icon(Icons.visibility),
                    label: const Text('Visualizar URL'),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar e entrar'),
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

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.black.withOpacity(0.18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
