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

  bool _loadingLogin = false;
  bool _loadingZip = false;
  bool _loadingPurge = false;
  String? _zipPath;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
  setState(() => _loadingLogin = true);
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
      if (mounted) setState(() => _loadingLogin = false);
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

  setState(() => _loadingZip = true);
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
      if (mounted) setState(() => _loadingZip = false);
    }
  }

  Future<void> _purgeAll() async {
    final token = await _auth.currentIdToken();
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Inicia sesión como admin')));
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirmar purga'),
            content: const Text(
              'Se eliminarán TODOS los registros.\n'
              'Sugerencia: exporta el ZIP antes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Borrar todo'),
              ),
            ],
          ),
    );
    if (ok != true) return;

  if (_loadingZip || _loadingPurge) return;
  setState(() => _loadingPurge = true);

    try {
      // llama al ApiClient como a downloadZip
      final res = await _api.purgeAll(
        idToken: token,
        deletePhotos: true, // pon false si no quieres borrar fotos
      );

      if (!mounted) return;
      setState(() => _zipPath = null);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Purga completada. Registros: ${res.deletedParticipants}, '
            'Fotos: ${res.deletedPhotos}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error purgando: $e')));
    } finally {
      if (mounted) setState(() => _loadingPurge = false);
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
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(24),
          shrinkWrap: true,
          children: [
            if (!logged) ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Iniciar sesión',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passCtrl,
                          decoration: _dec('Contraseña'),
                          obscureText: true,
                          validator:
                              (v) =>
                                  (v == null || v.isEmpty) ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: (_loadingLogin || _loadingZip || _loadingPurge) ? null : _login,
                            child: _loadingLogin
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Entrar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 32,
                    horizontal: 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 260,
                        child: FilledButton.icon(
                          onPressed: (_loadingZip || _loadingPurge) ? null : _downloadZip,
                          icon: _loadingZip
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: const Text('Descargar ZIP'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 260,
                        child: FilledButton.icon(
                          onPressed: (_loadingZip || _loadingPurge) ? null : _purgeAll,
                          icon: _loadingPurge
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.delete),
                          label: const Text('Borrar base de datos'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 260,
                        child: OutlinedButton.icon(
                          onPressed: (_loadingZip || _loadingPurge) ? null : _logout,
                          icon: const Icon(Icons.logout),
                          label: const Text('Salir'),
                        ),
                      ),
                      if (_zipPath != null) ...[
                        const SizedBox(height: 24),
                        SelectableText('Archivo: $_zipPath'),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'Nota: el ZIP incluye un Excel con datos y las fotos autenticadas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
