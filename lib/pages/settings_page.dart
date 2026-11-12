import 'package:flutter/material.dart';
import '../services/app_storage.dart';

class SettingsPages extends StatefulWidget {
  final VoidCallback onLogout;
  final ValueChanged<bool> onThemeChanged;

  const SettingsPages({
    super.key,
    required this.onLogout,
    required this.onThemeChanged,
  });

  @override
  State<SettingsPages> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPages> {
  final AppStorage _appStorage = AppStorage();
  bool _isLoading = true;
  bool _darkMode = false;
  bool _confirmDelete = true;

  @override
  void InitState() {
    super.initState();
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final settings = await _appStorage.loadSettings();
    setState(() {
      _darkMode = settings.darkMode;
      _confirmDelete = settings.confirmDelete;
      _isLoading = false;
    });
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      _darkMode = value;
    });

    await _appStorage.saveDarkMode(value);
    widget.onThemeChanged(value);
  }

  Future<void> _toggleConfirmDelete(bool value) async {
    setState(() {
      _confirmDelete = value;
    });

    await _appStorage.saveConformDelete(value);
  }

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Deseja sair da conta?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sair'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await _appStorage.setLoggedIn(false);

      if (!mounted) {
        return;
      }

      Navigator.pop(context);

      widget.onLogout();
    }
  }

  Future<void> _changedPassword() async {
    final changed = await showDialog(
      context: context,
      builder: (context) {
        return _ChangePasswordDialog(appStorage: _appStorage);
      },
    );

    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Senha alterada com sucesso"')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const _SectionTitle('Aparência'),
                SwitchListTile(
                  title: const Text('Modo Escuro'),
                  subtitle: Text(_darkMode ? 'Ativado' : 'Desativado'),
                  value: _darkMode,
                  onChanged: _toggleDarkMode,
                ),
                const _SectionTitle('TAREFAS'),
                SwitchListTile(
                  title: const Text('Confirmar exclusão'),
                  subtitle: const Text(
                    'Pedir confirmação antes de apagar uma tarefa',
                  ),
                  value: _confirmDelete,
                  onChanged: _toggleConfirmDelete,
                ),
                const _SectionTitle('CONTA'),
                ListTile(
                  title: const Text('Alterar senha'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _confirmLogout,
                ),
                const _SectionTitle('SOBRE'),
                const ListTile(
                  title: Text('Minhas tarefas'),
                  subtitle: Text('Versão 1.0.0'),
                ),
              ],
            ),
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  final AppStorage appStorage;

  const _ChangePasswordDialog({required this.appStorage});

  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _errorMensage;
  bool _isSaving = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _currentController.text.trim();
    final next = _newController.text.trim();
    final confirm = _confirmController.text.trim();
    final savedPassword = await widget.appStorage.loadPassword();

    if (!mounted) {
      return;
    }

    if (current != savedPassword) {
      setState(() {
        _errorMensage = 'Senha atual incorreta';
      });
      return;
    }
    if (next.isEmpty) {
      setState(() {
        _errorMensage = 'A nova senha não pode ficar vazia';
      });
      return;
    }
    if (next != confirm) {
      setState(() {
        _errorMensage = 'A confirmação não confere com a nova senha';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMensage = null;
    });

    await widget.appStorage.savePassword(next);

    if (!mounted) {
      return;
    }

    Navigator.pop(context, true);

    @override
    Widget build(BuildContext context) {
      return AlertDialog(
        title: const Text('Alterar minha senha'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _currentController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha atual'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nova Senha'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmar nova senha',
                ),
              ),
              if (_errorMensage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMensage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: _isSaving ? null : _save,
            child: const Text('Salvar'),
          ),
        ],
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
