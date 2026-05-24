import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    final required = _required(value);
    if (required != null) return required;

    if (value!.trim().length > 15) {
      return 'Máximo de 15 caracteres';
    }

    return null;
  }

  String? _url(String? value) {
    final required = _required(value);
    if (required != null) return required;

    final text = value!.trim();
    final uri = Uri.tryParse(text);

    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return 'URL inválida';
    }

    if (!text.startsWith('http://') && !text.startsWith('https://')) {
      return 'A URL precisa começar com http:// ou https://';
    }

    return null;
  }

  String _cleanUrl(String url) {
    return url.trim();
  }

  String _buildFinalUrl() {
    if (_manualMode) {
      return _cleanUrl(_manualUrlController.text);
    }

    return _selectedProfile.buildM3uUrl(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  Future<void> _saveAndEnter() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    try {
      final playlistUrl = _buildFinalUrl();

      final config = ServerConfig(
        serverName: _manualMode ? 'Lista Manual' : _selectedProfile.name,
        playlistUrl: playlistUrl,
        isManualUrl: _manualMode,
        profileId: _manualMode ? null : _selectedProfile.id,
        username: _manualMode ? null : _usernameController.text.trim(),
        password: _manualMode ? null : _passwordController.text.trim(),
        userAgent: 'Mozilla/5.0',
      );

      await const ServerConfigService().save(config);

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
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
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final url = _buildFinalUrl();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('URL gerada'),
        content: SelectableText(url),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
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
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                                      style: const TextStyle(color: Colors.white),
                                      items: ServerProfiles.all.map((profile) {
                                        return DropdownMenuItem<ServerProfile>(
                                          value: profile,
                                          child: Text(profile.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
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
                                        onChanged: (value) {
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
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _inputDecoration(label: 'Usuário'),
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
                                        style: const TextStyle(color: Colors.white),
                                        decoration: _inputDecoration(
                                          label: 'Senha',
                                          suffixIcon: IconButton(
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword = !_obscurePassword;
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
                                  validator: _url,
                                  minLines: 2,
                                  maxLines: 3,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: _inputDecoration(label: 'URL M3U'),
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
                                          color: Colors.white.withValues(alpha: 0.18),
                                        ),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: _saving ? null : _saveAndEnter,
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
                                        _saving ? 'Salvando...' : 'Salvar e entrar',
                                      ),
                                      style: FilledButton.styleFrom(
                                        minimumSize: const Size.fromHeight(52),
                                        backgroundColor: const Color(0xFFE50914),
                                        foregroundColor: Colors.black,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(18),
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
}        username: _usernameController.text,
        password: _passwordController.text,
      );

      if (_manualMode) {
        final entry = ServerEntry(
          id: _selectedEntryId?.startsWith('manual_') == true
              ? _selectedEntryId!
              : 'manual_${DateTime.now().millisecondsSinceEpoch}',
          name: _manualNameController.text.trim(),
          playlistUrl: _manualUrlController.text.trim(),
          isManual: true,
          userAgent: 'Mozilla/5.0',
        );
        await _service.upsertEntry(entry);
      } else {
        final entry = ServerEntry(
          id: _selectedProfile.id,
          name: _selectedProfile.name,
          playlistUrl: _selectedProfile.buildM3uUrl(
            username: _usernameController.text,
            password: _passwordController.text,
          ),
          isManual: false,
          profileId: _selectedProfile.id,
          userAgent: 'Mozilla/5.0',
        );
        await _service.upsertEntry(entry);
      }

      if (!mounted) return;

      setState(() => _saving = false);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _saving = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar: $e')),
      );
    }
  }

  Future<void> _selectSavedEntry(String? id) async {
    if (id == null || id.isEmpty) return;

    final entry = _entries
        .where((item) => item.id == id)
        .cast<ServerEntry?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (entry == null) return;

    await _service.setSelectedServerId(id);

    if (!mounted) return;

    setState(() {
      _selectedEntryId = id;
      _manualMode = entry.isManual;

      if (entry.isManual) {
        _manualNameController.text = entry.name;
        _manualUrlController.text = entry.playlistUrl;
      } else {
        _selectedProfile = ServerProfiles.firstById(entry.profileId ?? entry.id);
      }
    });
  }

  Future<void> _deleteSelectedManual() async {
    if (_selectedEntryId == null) return;

    final entry = _entries
        .where((item) => item.id == _selectedEntryId)
        .cast<ServerEntry?>()
        .firstWhere((item) => item != null, orElse: () => null);

    if (entry == null || !entry.isManual) return;

    await _service.deleteEntry(entry.id);
    _manualNameController.clear();
    _manualUrlController.clear();
    await _loadInitialState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final manualEntries = _entries.where((item) => item.isManual).toList();

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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Configuração do servidor',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'As credenciais ficam salvas com segurança e podem ser reutilizadas entre servidores.',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.65),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (_entries.isNotEmpty) ...[
                                DropdownButtonFormField<String>(
                                  value: _selectedEntryId,
                                  decoration: const InputDecoration(
                                    labelText: 'Lista salva',
                                  ),
                                  items: _entries
                                      .map(
                                        (entry) => DropdownMenuItem<String>(
                                          value: entry.id,
                                          child: Text(entry.name),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: _selectSavedEntry,
                                ),
                                const SizedBox(height: 16),
                              ],
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Expanded(
                                    child: _manualMode
                                        ? TextFormField(
                                            controller: _manualNameController,
                                            validator: _manualNameValidator,
                                            decoration: const InputDecoration(
                                              labelText: 'Nome da lista',
                                            ),
                                          )
                                        : DropdownButtonFormField<ServerProfile>(
                                            value: _selectedProfile,
                                            decoration: const InputDecoration(
                                              labelText: 'Servidor',
                                            ),
                                            items: ServerProfiles.all
                                                .map(
                                                  (profile) =>
                                                      DropdownMenuItem<ServerProfile>(
                                                    value: profile,
                                                    child: Text(profile.name),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (value) {
                                              if (value == null) return;
                                              setState(() => _selectedProfile = value);
                                            },
                                          ),
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.04),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.white.withValues(alpha: 0.08),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Lista manual',
                                          style: TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(width: 10),
                                        Switch(
                                          value: _manualMode,
                                          onChanged: (value) {
                                            setState(() {
                                              _manualMode = value;
                                              if (!value) {
                                                _manualNameController.clear();
                                                _manualUrlController.clear();
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (!_manualMode) ...[
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _usernameController,
                                        validator: _credentialValidator,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(15),
                                        ],
                                        decoration: const InputDecoration(
                                          labelText: 'Usuário',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _passwordController,
                                        validator: _credentialValidator,
                                        obscureText: true,
                                        inputFormatters: [
                                          LengthLimitingTextInputFormatter(15),
                                        ],
                                        decoration: const InputDecoration(
                                          labelText: 'Senha',
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
                                  decoration: const InputDecoration(
                                    labelText: 'URL M3U',
                                  ),
                                ),
                                if (manualEntries.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: _deleteSelectedManual,
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text(
                                        'Excluir lista manual selecionada',
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _saving ? null : _save,
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    backgroundColor: const Color(0xFFE50914),
                                    foregroundColor: Colors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
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
                                    _saving ? 'Salvando...' : 'Salvar e entrar',
                                  ),
                                ),
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
}  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    await _service.saveCredentials(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (_manualMode) {
      final entry = ServerEntry(
        id: _selectedEntryId?.startsWith('manual_') == true
            ? _selectedEntryId!
            : 'manual_${DateTime.now().millisecondsSinceEpoch}',
        name: _manualNameController.text.trim(),
        playlistUrl: _manualUrlController.text.trim(),
        isManual: true,
        userAgent: 'Mozilla/5.0',
      );
      await _service.upsertEntry(entry);
    } else {
      final entry = ServerEntry(
        id: _selectedProfile.id,
        name: _selectedProfile.name,
        playlistUrl: _selectedProfile.buildM3uUrl(
          username: _usernameController.text,
          password: _passwordController.text,
        ),
        isManual: false,
        profileId: _selectedProfile.id,
        userAgent: 'Mozilla/5.0',
      );
      await _service.upsertEntry(entry);
    }

    if (!mounted) return;

    setState(() => _saving = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  Future<void> _selectSavedEntry(String? id) async {
    if (id == null || id.isEmpty) return;

    final entry = _entries.where((item) => item.id == id).cast<ServerEntry?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );

    if (entry == null) return;

    await _service.setSelectedServerId(id);

    if (!mounted) return;

    setState(() {
      _selectedEntryId = id;
      _manualMode = entry.isManual;
      if (entry.isManual) {
        _manualNameController.text = entry.name;
        _manualUrlController.text = entry.playlistUrl;
      } else {
        _selectedProfile = ServerProfiles.firstById(entry.profileId ?? entry.id);
      }
    });
  }

  Future<void> _deleteSelectedManual() async {
    if (_selectedEntryId == null) return;

    final entry = _entries.where((item) => item.id == _selectedEntryId).cast<ServerEntry?>().firstWhere(
          (item) => item != null,
          orElse: () => null,
        );

    if (entry == null || !entry.isManual) return;

    await _service.deleteEntry(entry.id);
    _manualNameController.clear();
    _manualUrlController.clear();
    await _loadInitialState();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final manualEntries = _entries.where((item) => item.isManual).toList();

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
              constraints: const BoxConstraints(maxWidth: 920),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Configuração do servidor',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'As credenciais ficam salvas com segurança e podem ser reutilizadas entre servidores.',
                          style: TextStyle(color: Colors.white.withOpacity(0.65)),
                        ),
                        const SizedBox(height: 20),
                        if (_entries.isNotEmpty) ...[
                          DropdownButtonFormField<String>(
                            value: _selectedEntryId,
                            decoration: const InputDecoration(labelText: 'Lista salva'),
                            items: _entries
                                .map(
                                  (entry) => DropdownMenuItem<String>(
                                    value: entry.id,
                                    child: Text(entry.name),
                                  ),
                                )
                                .toList(),
                            onChanged: _selectSavedEntry,
                          ),
                          const SizedBox(height: 16),
                        ],
                        SwitchListTile(
                          value: _manualMode,
                          onChanged: (value) {
                            setState(() {
                              _manualMode = value;
                              if (!value) {
                                _manualNameController.clear();
                                _manualUrlController.clear();
                              }
                            });
                          },
                          title: const Text('Lista manual'),
                          contentPadding: EdgeInsets.zero,
                        ),
                        const SizedBox(height: 12),
                        if (!_manualMode) ...[
                          DropdownButtonFormField<ServerProfile>(
                            value: _selectedProfile,
                            decoration: const InputDecoration(labelText: 'Servidor'),
                            items: ServerProfiles.all
                                .map(
                                  (profile) => DropdownMenuItem<ServerProfile>(
                                    value: profile,
                                    child: Text(profile.name),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _selectedProfile = value);
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _usernameController,
                                  validator: _credentialValidator,
                                  inputFormatters: [LengthLimitingTextInputFormatter(15)],
                                  decoration: const InputDecoration(labelText: 'Usuário'),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _passwordController,
                                  validator: _credentialValidator,
                                  obscureText: true,
                                  inputFormatters: [LengthLimitingTextInputFormatter(15)],
                                  decoration: const InputDecoration(labelText: 'Senha'),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          TextFormField(
                            controller: _manualNameController,
                            validator: _manualNameValidator,
                            decoration: const InputDecoration(labelText: 'Nome da lista'),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _manualUrlController,
                            validator: _urlValidator,
                            minLines: 2,
                            maxLines: 3,
                            decoration: const InputDecoration(labelText: 'URL M3U'),
                          ),
                          if (manualEntries.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: _deleteSelectedManual,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Excluir lista manual selecionada'),
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.save),
                            label: Text(_saving ? 'Salvando...' : 'Salvar e entrar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
