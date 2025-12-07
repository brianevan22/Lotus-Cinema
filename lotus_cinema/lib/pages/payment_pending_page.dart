import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../api_service.dart';
import '../theme/app_theme.dart';

class PaymentPendingPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const PaymentPendingPage({super.key, required this.data});

  @override
  State<PaymentPendingPage> createState() => _PaymentPendingPageState();
}

class _PaymentPendingPageState extends State<PaymentPendingPage> {
  final api = ApiService();
  late Map<String, dynamic> _data;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _data = Map<String, dynamic>.from(widget.data);
  }

  Map<String, dynamic> get _paymentOption {
    final option = _data['payment_option'];
    if (option is Map) {
      return Map<String, dynamic>.from(option);
    }
    final rawMethod = (_data['payment_method'] ?? '').toString();
    final destination = (_data['payment_destination'] ?? '').toString();
    final fallbackOwner = _data['payment_owner']?.toString();
    return {
      'code': rawMethod,
      'title': _methodDisplayName(rawMethod),
      'account_number': destination.isNotEmpty ? destination : '-',
      'owner':
          (fallbackOwner?.isNotEmpty ?? false) ? fallbackOwner : 'Lotus Cinema',
      'is_qris': rawMethod.toUpperCase() == 'QRIS',
      if (rawMethod.toUpperCase() == 'QRIS') 'asset_path': 'assets/QRIS.png',
      'note':
          'Pastikan nama rekening pengirim sesuai data yang Anda isi saat checkout.',
    };
  }

  bool get _isPending {
    final status = (_data['status'] ?? '').toString().toLowerCase();
    return status.isEmpty || status == 'pending';
  }

  String _methodDisplayName(String method) {
    final normalized = method.toUpperCase();
    switch (normalized) {
      case 'BCA':
        return 'Transfer Bank BCA';
      case 'BRI':
        return 'Transfer Bank BRI';
      case 'QRIS':
        return 'QRIS Lotus Cinema';
      case 'MANDIRI':
        return 'Transfer Bank Mandiri';
      default:
        return method.isEmpty ? 'Metode Pembayaran' : method;
    }
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

  Future<void> _copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Disalin ke clipboard')));
  }

  Future<void> _cancelPayment() async {
    final trxId = _data['transaksi_id'];
    if (trxId == null) return;
    setState(() => _cancelling = true);
    try {
      final updated = await api.updateTransactionStatus(trxId as int, 'batal');
      setState(() => _data = {..._data, ...updated});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pembayaran dibatalkan.')));
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membatalkan pembayaran: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  void _goHome() {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final option = _paymentOption;
    final account = option['account_number']?.toString() ?? '-';
    final owner = option['owner']?.toString() ?? 'Lotus Cinema';
    final title = option['title']?.toString() ?? _methodDisplayName('');
    final note = option['note']?.toString();
    final isQris = option['is_qris'] == true;
    final qrAsset = option['asset_path']?.toString();
    final senderAccountName =
        (_data['payment_account_name'] ?? '').toString().trim();

    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppTheme.buildGradientAppBar(context, 'Menunggu Pembayaran'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withOpacity(.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Status Pembayaran',
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(_isPending ? Icons.schedule : Icons.highlight_off,
                        color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      _isPending ? 'Pending' : 'Dibatalkan',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _isPending
                      ? 'Admin akan memverifikasi pembayaran Anda.\nSetelah status berubah menjadi sukses, tiket dapat dicetak dari menu riwayat transaksi.'
                      : 'Transaksi ini telah dibatalkan. Anda dapat melakukan pemesanan ulang bila masih ingin melanjutkan.',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Detail Pembayaran',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _infoRow(
                      'No. Transaksi', '#${_data['transaksi_id'] ?? '-'}', cs),
                  _infoRow('Total Bayar',
                      'Rp ${_formatCurrency(_data['total_harga'])}', cs,
                      highlight: true),
                  _infoRow('Metode', title, cs),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: cs.surfaceVariant.withOpacity(.35),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isQris
                              ? 'ID Merchant / QRIS Lotus Cinema'
                              : 'Nomor Rekening',
                          style: TextStyle(
                              fontSize: 13, color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                account,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: cs.onSurface,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: account == '-' || account.isEmpty
                                  ? null
                                  : () => _copyText(account),
                              icon: const Icon(Icons.copy, size: 18),
                            ),
                          ],
                        ),
                        Text('a.n. $owner',
                            style: TextStyle(color: cs.onSurfaceVariant)),
                        if (senderAccountName.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Atas nama pengirim',
                              style: TextStyle(
                                  fontSize: 12, color: cs.onSurfaceVariant)),
                          Text(
                            senderAccountName,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface),
                          ),
                        ],
                        if (note != null && note.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(note,
                              style: TextStyle(
                                  fontSize: 12, color: cs.onSurfaceVariant)),
                        ],
                        if (isQris) ...[
                          const SizedBox(height: 14),
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.asset(
                                qrAsset != null && qrAsset.isNotEmpty
                                    ? qrAsset
                                    : 'assets/QRIS.png',
                                width: 220,
                                height: 260,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                              'Tunjukkan / scan QR ini pada aplikasi bank/e-wallet.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: cs.onSurfaceVariant)),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if ((_data['seat_labels'] ?? '').toString().isNotEmpty)
                    _infoRow('Kursi', _data['seat_labels'].toString(), cs),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Langkah penyelesaian:',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  SizedBox(height: 8),
                  _StepItem(
                    icon: Icons.circle,
                    label:
                        'Transfer sesuai nominal ke rekening / QRIS yang dipilih.',
                  ),
                  _StepItem(
                    icon: Icons.circle,
                    label:
                        'Tulis catatan atau kirim bukti via form catatan saat checkout.',
                  ),
                  _StepItem(
                    icon: Icons.circle,
                    label:
                        'Tunggu admin memverifikasi. Anda dapat memantau status pada menu Riwayat Transaksi.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.home),
                label: const Text('Kembali ke Home'),
              ),
              const SizedBox(height: 10),
              if (_isPending)
                OutlinedButton.icon(
                  onPressed: _cancelling ? null : _cancelPayment,
                  icon: _cancelling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.cancel_schedule_send),
                  label: const Text('Batalkan Pembayaran'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, ColorScheme cs,
      {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              color: highlight ? cs.primary : cs.onSurface,
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StepItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 12, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
