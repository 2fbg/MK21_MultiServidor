import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/home/home_page.dart';
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
  final _manualNameController = TextEditingController();
  final _manualUrlController = TextEditingController();

  final _service = const ServerConfigService();

  ServerProfile _selectedProfile = ServerProfiles.all.first;
  bool _manualMode = false;
  bool _loading = true;
  bool _saving = false;
  List<ServerEntry> _entries = const [];
  String? _selectedEntryId;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _manualNameController.dispose();
    _manualUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialState() async {
    final entries = await _service.loadEntries();
    final selectedId = await _service.loadSelectedServerId();
    final credentials = await _service.loadCredentials();

    if (!mounted) return;

    setState(() {
      _entries = entries;
      _selectedEntryId = selectedId;
      _usernameController.text = credentials.username;
      _passwordController.text = credentials.password;
      _loading = false;
    });
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

  String? _manualNameValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    if (value!.trim().length < 3) {
      return 'Digite um nome mais descritivo';
    }
    return null;
  }

  String? _urlValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;

    final uri = Uri.tryParse(value!.trim());
    if (uri == null || !(uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'))) {
      return 'URL inválida';
    }

    return null;
  }

  Future<void> _save() async {
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
