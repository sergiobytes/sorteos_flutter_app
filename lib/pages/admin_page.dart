import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _form = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final _auth = AuthService();
  final _api = ApiClient();

  bool _loading = false;
  String? _zipPath;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _auth.signIn(_emailCtrl.text.trim(), _passCtrl.text);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Admin conectado')));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Auth error: ${e.code}')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _downloadZip() async {
    final token = await _auth.currentIdToken();
    if (token == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Inicia sesión primero')));
      return;
    }

    setState(() => _loading = true);
    try {
      final tmpDir = await getTemporaryDirectory();
      final fileName =
          'sorteo_export_${DateTime.now().millisecondsSinceEpoch}.zip';
      final tmpPath = '${tmpDir.path}/$fileName';

      await _api.downloadZip(idToken: token, savePath: tmpPath);

      if (!mounted) return;
      setState(() => _zipPath = tmpPath);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ZIP descargado: $fileName')));

      await SharePlus.instance.share(
        ShareParams(
          text: 'Exportación del sorteo',
          subject: 'Exportación del sorteo',
          files: [XFile(tmpPath, mimeType: 'application/zip', name: fileName)],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error descargando: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (!mounted) return;
    setState(() => _zipPath = null);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Sesión cerrada')));
  }

  InputDecoration _dec(String label) =>
      InputDecoration(labelText: label, border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    final logged = _auth.isLoggedIn;

    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!logged) ...[
            Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Iniciar sesión',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _dec('Email'),
                    validator:
                        (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Requerido'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passCtrl,
                    decoration: _dec('Contraseña'),
                    obscureText: true,
                    validator:
                        (v) => (v == null || v.isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: _loading ? null : _login,
                    child:
                        _loading
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                            : const Text('Entrar'),
                  ),
                ],
              ),
            ),
          ] else ...[
            Row(
              children: [
                FilledButton.icon(
                  onPressed: _loading ? null : _downloadZip,
                  icon:
                      _loading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.download),
                  label: const Text('Descargar ZIP'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Salir'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_zipPath != null) SelectableText('Archivo: $_zipPath'),
            const SizedBox(height: 24),
            const Text(
              'Nota: el ZIP incluye un Excel con datos enmascarados y las fotos autenticadas.',
            ),
          ],
        ],
      ),
    );
  }
}
