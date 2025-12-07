import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api_service.dart';
import '../../theme/app_theme.dart';

class AdminTransactionDetailPage extends StatefulWidget {
  final int transaksiId;
  final Map<String, dynamic>? initial;
  const AdminTransactionDetailPage({
    super.key,
    required this.transaksiId,
    this.initial,
  });

  @override
  State<AdminTransactionDetailPage> createState() =>
      _AdminTransactionDetailPageState();
}

class _AdminTransactionDetailPageState
    extends State<AdminTransactionDetailPage> {
  final api = ApiService();
  Map<String, dynamic>? _trx;
  bool _loading = true;
  String? _error;
  bool _updating = false;
  final DateFormat _fullDateFormat = DateFormat('dd MMM yyyy • HH:mm');
  final DateFormat _dateOnlyFormat = DateFormat('dd MMM yyyy');

  @override
  void initState() {
    super.initState();
    _trx = widget.initial != null
        ? Map<String, dynamic>.from(widget.initial!)
        : null;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await api.transactionDetail(widget.transaksiId);
      setState(() => _trx = data);
    } catch (e) {
      setState(() => _error = 'Gagal memuat transaksi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _updating = true);
    try {
      final data =
          await api.updateTransactionStatus(widget.transaksiId, status);
      setState(() => _trx = data);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Status diperbarui')));
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal update status: $e')));
      }
    } finally {
      if (mounted) setState(() => _updating = false);
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

  DateTime? _parseDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    if (raw is String) {
      final value = raw.trim();
      if (value.isEmpty) return null;
      final normalized =
          value.contains('T') ? value : value.replaceFirst(' ', 'T');
      return DateTime.tryParse(normalized);
    }
    if (raw is int || raw is double) {
      return DateTime.fromMillisecondsSinceEpoch((raw as num).toInt());
    }
    return null;
  }

  String? _formatDateTimeLabel(dynamic raw) {
    final dt = _parseDateTime(raw);
    if (dt == null) return null;
    return _fullDateFormat.format(dt.toLocal());
  }

  String? _formatDateOnly(dynamic raw) {
    final dt = _parseDateTime(raw);
    if (dt == null) return null;
    return _dateOnlyFormat.format(dt.toLocal());
  }

  String? _formatSchedule(Map<String, dynamic>? jadwal) {
    if (jadwal == null || jadwal.isEmpty) return null;
    final tanggal = _formatDateOnly(jadwal['tanggal']);
    final jamMulai = _formatTimeLabel(jadwal['jam_mulai']?.toString());
    final jamSelesai = _formatTimeLabel(jadwal['jam_selesai']?.toString());
    final jamLabel = [jamMulai, jamSelesai]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .join(' - ');
    final parts = [tanggal, jamLabel.isEmpty ? null : jamLabel]
        .whereType<String>()
        .toList();
    if (parts.isEmpty) return null;
    return parts.join(' • ');
  }

  String? _formatTimeLabel(String? value) {
    if (value == null || value.isEmpty) return null;
    final segments = value.split(':');
    if (segments.length >= 2) {
      final hh = segments[0].padLeft(2, '0');
      final mm = segments[1].padLeft(2, '0');
      return '$hh:$mm';
    }
    return value;
  }

  Widget _metaRow(IconData icon, String label, String value, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                Text(
                  value,
                  style: TextStyle(
                      fontWeight: FontWeight.w600, color: cs.onSurface),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final trx = _trx;
    final senderName = (trx?['payment_account_name'] ?? '').toString().trim();
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppTheme.buildGradientAppBar(context, 'Detail Transaksi'),
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
                            onPressed: _load, child: const Text('Coba Lagi')),
                      ],
                    ),
                  ),
                )
              : trx == null
                  ? const SizedBox.shrink()
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Transaksi #${trx['transaksi_id']}'),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: _statusColor(cs, trx['status'])
                                            .withOpacity(.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _statusLabel(trx['status']),
                                        style: TextStyle(
                                            color:
                                                _statusColor(cs, trx['status']),
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Total: Rp ${_formatCurrency(trx['total_harga'])}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (trx['customer'] is Map)
                                  Text(
                                    'Customer: ${(trx['customer']['nama'] ?? trx['customer']['name'] ?? '-').toString()}',
                                  ),
                                if (_formatDateTimeLabel(
                                        trx['tanggal_transaksi']) !=
                                    null)
                                  Text(
                                      'Tanggal: ${_formatDateTimeLabel(trx['tanggal_transaksi'])}'),
                                if (_formatDateTimeLabel(trx['paid_at']) !=
                                    null)
                                  Text(
                                      'Dibayar: ${_formatDateTimeLabel(trx['paid_at'])}'),
                                if (trx['payment_method'] != null)
                                  Text('Metode: ${trx['payment_method']}'),
                                if (trx['payment_destination'] != null)
                                  Text('Tujuan: ${trx['payment_destination']}'),
                                if (senderName.isNotEmpty)
                                  Text('Atas Nama Pengirim: $senderName'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Detail Kursi',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.w700)),
                                const SizedBox(height: 12),
                                Builder(builder: (context) {
                                  final film = trx['film'] is Map
                                      ? Map<String, dynamic>.from(
                                          trx['film'] as Map)
                                      : null;
                                  final jadwal = trx['jadwal'] is Map
                                      ? Map<String, dynamic>.from(
                                          trx['jadwal'] as Map)
                                      : null;
                                  Map<String, dynamic>? studio;
                                  if (trx['studio'] is Map) {
                                    studio = Map<String, dynamic>.from(
                                        trx['studio'] as Map);
                                  } else if (jadwal?['studio'] is Map) {
                                    studio = Map<String, dynamic>.from(
                                        jadwal!['studio'] as Map);
                                  }

                                  final filmTitle = film == null
                                      ? null
                                      : film['judul']?.toString();
                                  final studioName = studio == null
                                      ? null
                                      : (studio['nama_studio'] ??
                                              studio['nama'])
                                          ?.toString();
                                  final scheduleLabel = _formatSchedule(jadwal);

                                  final widgets = <Widget>[];
                                  if (filmTitle != null &&
                                      filmTitle.isNotEmpty) {
                                    widgets.add(_metaRow(
                                        Icons.movie, 'Film', filmTitle, cs));
                                  }
                                  if (studioName != null &&
                                      studioName.isNotEmpty) {
                                    widgets.add(_metaRow(Icons.chair_alt,
                                        'Studio', studioName, cs));
                                  }
                                  if (scheduleLabel != null &&
                                      scheduleLabel.isNotEmpty) {
                                    widgets.add(_metaRow(Icons.schedule,
                                        'Jadwal', scheduleLabel, cs));
                                  }

                                  final kursiList = trx['kursi'] is List
                                      ? (trx['kursi'] as List)
                                          .whereType<Map>()
                                          .map((e) =>
                                              Map<String, dynamic>.from(e))
                                          .toList()
                                      : <Map<String, dynamic>>[];

                                  if (widgets.isNotEmpty &&
                                      kursiList.isNotEmpty) {
                                    widgets.add(const Divider(height: 24));
                                  }

                                  if (kursiList.isNotEmpty) {
                                    widgets.addAll(List.generate(
                                        kursiList.length, (index) {
                                      final seat = kursiList[index];
                                      return ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Text(
                                            seat['nomor_kursi']?.toString() ??
                                                'Kursi'),
                                        subtitle: Text(
                                            'Harga: Rp ${_formatCurrency(seat['harga'])}'),
                                      );
                                    }));
                                  } else {
                                    widgets.add(const Text('-'));
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: widgets,
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
      bottomNavigationBar: trx == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            _updating ? null : () => _updateStatus('pending'),
                        child: const Text('Pending'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            _updating ? null : () => _updateStatus('sukses'),
                        child: _updating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Tandai Sukses'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
