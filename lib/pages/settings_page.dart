import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:flutter/material.dart';
import '../services/app_storage.dart';

class SettingsPage extends StatefulWidget {
  final VoidCallback onLogin;
  final ValueChanged<bool> onThemeChanged;

  const SettingsPage({
    super.key,
    required this.onLogin,
    required this.onThemeChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppStorage _appStorage = AppStorage();
  bool _isLoading = true;
  bool _darkMode = true;
  bool _confirmMode = true;

  @override
  void initState() {
    super.initState();
    _loadingSettings();
  }

  Future<void> _loadingSettings() async {
    final settings = await _appStorage.loadSettings();
    setState(() {
      _darkMode = settings.darkmode;
      _confirmMode = settings.confirmDelete;
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

  Future<void> _confirmLogout() async {
    final shouldLogout = await showDialog<Bool>(
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
            FilledButton(
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

      widget.onLogin;
    }
  }
}
