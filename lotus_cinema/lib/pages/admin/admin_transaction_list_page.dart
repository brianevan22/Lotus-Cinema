import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../theme/app_theme.dart';
import 'admin_transaction_detail_page.dart';

class AdminTransactionListPage extends StatefulWidget {
  const AdminTransactionListPage({super.key});

  @override
  State<AdminTransactionListPage> createState() =>
      _AdminTransactionListPageState();
}

class _AdminTransactionListPageState extends State<AdminTransactionListPage>
    with SingleTickerProviderStateMixin {
  final api = ApiService();
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  String _filter = 'pending';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await api.transactions(
        perPage: 100,
        status: _filter == 'all' ? null : _filter,
        onlyPending: _filter == 'pending',
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

  String _formatCurrency(dynamic raw) {
    final value = raw is num ? raw.toInt() : int.tryParse('$raw') ?? 0;
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final left = digits.length - i - 1;
      if (left > 0 && left % 3 == 0) buffer.write('.');
    }
    return (value < 0 ? '-' : '') + buffer.toString();
  }

  Future<void> _changeStatus(int id, String status) async {
    try {
      await api.updateTransactionStatus(id, status);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Status diperbarui')));
      }
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal update: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppTheme.buildGradientAppBar(context, 'Transaksi'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'pending', label: Text('Pending')),
                ButtonSegment(value: 'sukses', label: Text('Sukses')),
                ButtonSegment(value: 'all', label: Text('Semua')),
              ],
              selected: {_filter},
              onSelectionChanged: (value) {
                setState(() => _filter = value.first);
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
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
                                  child: const Text('Coba Lagi')),
                            ],
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _items.length,
                          itemBuilder: (context, index) {
                            final trx = _items[index];
                            final status = trx['status']?.toString();
                            final chipColor = _statusColor(cs, status);
                            final filmTitle = trx['film'] is Map
                                ? (trx['film']['judul'] ?? 'Tanpa Judul')
                                    .toString()
                                : (trx['film_title'] ?? 'Tanpa Judul')
                                    .toString();
                            final customer = trx['customer'] is Map
                                ? (trx['customer']['nama'] ??
                                        trx['customer']['name'] ??
                                        '-')
                                    .toString()
                                : '-';
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(filmTitle,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              Text('Customer: $customer'),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: chipColor.withOpacity(.12),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            _statusLabel(status),
                                            style: TextStyle(
                                                color: chipColor,
                                                fontWeight: FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                        'Total: Rp ${_formatCurrency(trx['total_harga'])}'),
                                    Text(
                                        'Tanggal: ${trx['tanggal_transaksi'] ?? '-'}'),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        if ((status ?? '').toLowerCase() ==
                                            'pending')
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _changeStatus(
                                                  trx['transaksi_id'],
                                                  'sukses'),
                                              child:
                                                  const Text('Tandai Sukses'),
                                            ),
                                          )
                                        else
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () => _changeStatus(
                                                  trx['transaksi_id'],
                                                  'pending'),
                                              child: const Text(
                                                  'Kembalikan Pending'),
                                            ),
                                          ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: FilledButton(
                                            onPressed: () async {
                                              final updated =
                                                  await Navigator.push<bool>(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      AdminTransactionDetailPage(
                                                    transaksiId:
                                                        trx['transaksi_id']
                                                            as int,
                                                    initial: trx,
                                                  ),
                                                ),
                                              );
                                              if (updated == true) {
                                                _load();
                                              }
                                            },
                                            child: const Text('Detail'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
