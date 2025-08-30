import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sorteos_app/services/api_client.dart';
import 'package:sorteos_app/services/upload_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _form = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _walletCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  final _api = ApiClient();
  final _uploader = UploadService();

  File? _photo;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _walletCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final file = await _uploader.takePhoto();
    if (!mounted) return;
    setState(() => _photo = file);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    if (_photo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Toma la foto de la INE')));
      return;
    }

    setState(() => _loading = true);

    try {
      final sign = await _api.getUploadSignature(
        _api.padWallet(_walletCtrl.text.trim()),
      );

      final cloud = await _api.uploadToCloudinary(
        signPayload: sign,
        imageFile: _photo!,
      );

      await _api.createParticipant(
        name: _nameCtrl.text.trim(),
        walletNumber: _api.padWallet(_walletCtrl.text.trim()),
        phone: _phoneCtrl.text.trim(),
        photoPublicId: cloud['public_id'] as String,
        photoVersion: cloud['version'] as String,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registro guardado')));

      setState(() {
        _photo = null;
        _nameCtrl.clear();
        _walletCtrl.clear();
        _phoneCtrl.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: const OutlineInputBorder(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro de Sorteo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => Navigator.of(context).pushNamed('/admin'),
            tooltip: 'Admin',
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32,
                  horizontal: 24,
                ),
                child: Form(
                  key: _form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _takePhoto,
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.grey.shade100,
                          ),
                          child:
                              _photo == null
                                  ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.camera_alt,
                                        size: 54,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Tocar para tomar foto de INE',
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  )
                                  : ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      _photo!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 200,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: _dec('Nombre completo'),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Requerido'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _walletCtrl,
                        decoration: _dec('Número de cartera'),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Requerido'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: _dec('Número de teléfono'),
                        validator:
                            (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Requerido'
                                    : null,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _loading ? null : _submit,
                          icon:
                              _loading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.save),
                          label: const Text('Guardar'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Aviso: La foto se guarda en almacenamiento privado y el teléfono se protege.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
