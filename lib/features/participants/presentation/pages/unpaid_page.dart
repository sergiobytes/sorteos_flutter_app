import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/data/datasources/api_client.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/admin_prefs.dart';

class UnpaidPage extends StatefulWidget {
  const UnpaidPage({super.key});

  @override
  State<UnpaidPage> createState() => _UnpaidPageState();
}

class _UnpaidPageState extends State<UnpaidPage> {
  final _api = ApiClient();
  final _auth = AuthService();
  final _searchCtrl = TextEditingController();

  List<Participant> _items = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
  await _fetch(); // primer fetch sin filtro
  }

  Future<void> _fetch([String q = ""]) async {
    final token = await _auth.currentIdToken();
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Inicia sesión')));
      return;
    }
    setState(() => _loading = true);
    try {
      final data = await _api.fetchUnpaid(idToken: token, query: q);
      if (!mounted) return;
      setState(() => _items = data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => _fetch(v.trim()),
    );
  }

  Future<void> _confirmMark(Participant p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar pago'),
        content: Text(
          '¿Marcar como pagada la cartera ${p.walletNumber} de "${p.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final token = await _auth.currentIdToken();
    if (token == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Inicia sesión')));
      return;
    }

    setState(() => _loading = true);
    try {
      final email = await AdminPrefs.loadEmail() ?? "";
      await _api.markPaidByWallet(
        idToken: token,
        walletNumber: p.walletNumber,
        adminEmail: email,
      );
      await _fetch(_searchCtrl.text.trim()); // refresca lista
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Marcada cartera ${p.walletNumber}')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Carteras sin pagar')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre o cartera (ej. 120)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Actualizar',
                  onPressed: _loading ? null : () => _fetch(_searchCtrl.text.trim()),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _items.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay carteras pendientes',
                          style: TextStyle(fontSize: 18, color: Colors.black54),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final p = _items[i];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade100,
                                child: Text(p.walletNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              title: Text(
                                p.name,
                                style: theme.textTheme.titleMedium,
                              ),
                              subtitle: Text('Cartera: ${p.walletNumber}'),
                              trailing: FilledButton.icon(
                                onPressed: _loading ? null : () => _confirmMark(p),
                                icon: const Icon(Icons.verified),
                                label: const Text('Marcar pagado'),
                              ),
                              onTap: () => _confirmMark(p),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
