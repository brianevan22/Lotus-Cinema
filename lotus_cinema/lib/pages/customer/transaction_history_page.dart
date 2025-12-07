import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../theme/app_theme.dart';
import '../checkout_success_page.dart';
import '../payment_pending_page.dart';

class CustomerTransactionHistoryPage extends StatefulWidget {
  const CustomerTransactionHistoryPage({super.key});

  @override
  State<CustomerTransactionHistoryPage> createState() =>
      _CustomerTransactionHistoryPageState();
}

class _CustomerTransactionHistoryPageState
    extends State<CustomerTransactionHistoryPage> {
  final api = ApiService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  String _filter = 'all';
  int? _customerId;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final id = await api.getStoredCustomerId();
    if (!mounted) return;
    if (id == null) {
      setState(() {
        _error = 'Customer ID tidak ditemukan. Silakan login ulang.';
        _loading = false;
      });
      return;
    }
    setState(() => _customerId = id);
    await _load();
  }

  Future<void> _load() async {
    if (_customerId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await api.transactions(
        perPage: 100,
        status: _filter == 'all' ? null : _filter,
        customerId: _customerId,
      );
      final list = res.data
          .map((e) => e is Map
              ? Map<String, dynamic>.from(e as Map)
              : <String, dynamic>{})
          .where((m) => m.isNotEmpty)
          .toList();
      setState(() => _items = list);
    } catch (e) {
      setState(() => _error = 'Gagal memuat transaksi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _statusLabel(String? raw) {
    final value = (raw ?? '').toLowerCase();
    if (value == 'sukses' || value == 'success') return 'Sukses';
    if (value == 'batal' || value == 'cancel') return 'Dibatalkan';
    return 'Pending';
  }

  Color _statusColor(ColorScheme cs, String? raw) {
    final value = (raw ?? '').toLowerCase();
    if (value == 'sukses' || value == 'success') return cs.primary;
    if (value == 'batal' || value == 'cancel') return Colors.redAccent;
    return Colors.orange;
  }

  String _seatLabels(Map<String, dynamic> trx) {
    final kursi = trx['kursi'];
    if (kursi is List && kursi.isNotEmpty) {
      final labels = kursi
          .map((e) =>
              (e is Map ? e['nomor_kursi'] : null)?.toString().trim() ?? '')
          .where((label) => label.isNotEmpty)
          .toList();
      if (labels.isNotEmpty) return labels.join(', ');
    }
    final direct = trx['kursi_labels']?.toString();
    if (direct != null && direct.isNotEmpty) return direct;
    return '-';
  }

  Future<void> _handleTap(Map<String, dynamic> trx) async {
    final status = (trx['status'] ?? '').toString().toLowerCase();
    if (status == 'sukses' || status == 'success') {
      final payload = api.buildTicketPayloadFromTransaction(trx);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CheckoutSuccessPage(data: payload),
        ),
      );
    } else {
      final updated = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentPendingPage(data: trx),
        ),
      );
      if (updated == true && mounted) {
        _load();
      }
    }
  }

  Widget _buildFilterChips(ColorScheme cs) {
    final filters = [
      {'label': 'Semua', 'value': 'all'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Sukses', 'value': 'sukses'},
    ];
    return Wrap(
      spacing: 8,
      children: filters.map((f) {
        final selected = _filter == f['value'];
        return ChoiceChip(
          label: Text(f['label']!),
          selected: selected,
          onSelected: (_) {
            setState(() => _filter = f['value']!);
            _load();
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppTheme.buildGradientAppBar(context, 'Riwayat Transaksi'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildFilterChips(cs),
                      const SizedBox(height: 16),
                      if (_items.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: cs.surface,
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Column(
                            children: const [
                              Icon(Icons.receipt_long, size: 48),
                              SizedBox(height: 12),
                              Text(
                                'Belum ada transaksi.\nSilakan lakukan checkout terlebih dahulu.',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ..._items.map((trx) {
                          final status = trx['status']?.toString();
                          final chipColor = _statusColor(cs, status);
                          final filmTitle = trx['film'] is Map
                              ? (trx['film']['judul'] ?? 'Tanpa Judul')
                                  .toString()
                              : (trx['film_title'] ?? 'Tanpa Judul').toString();
                          final tanggal =
                              trx['tanggal_transaksi']?.toString() ?? '-';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18)),
                            child: ListTile(
                              onTap: () => _handleTap(trx),
                              title: Text(filmTitle,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tanggal: $tanggal'),
                                  Text('Kursi: ${_seatLabels(trx)}'),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: chipColor.withOpacity(.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _statusLabel(status),
                                  style: TextStyle(
                                      color: chipColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
    );
  }
}
