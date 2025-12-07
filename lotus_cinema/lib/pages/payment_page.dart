import 'package:flutter/material.dart';
import '../api_service.dart';
import '../theme/app_theme.dart';
import 'payment_pending_page.dart';

class PaymentOption {
  final String code;
  final String title;
  final String description;
  final IconData icon;
  final String accountNumber;
  final String owner;
  final bool isQris;
  final String? extraNote;
  final String? assetPath;

  const PaymentOption({
    required this.code,
    required this.title,
    required this.description,
    required this.icon,
    required this.accountNumber,
    required this.owner,
    this.isQris = false,
    this.extraNote,
    this.assetPath,
  });

  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
        'description': description,
        'account_number': accountNumber,
        'owner': owner,
        'is_qris': isQris,
        if (extraNote != null) 'note': extraNote,
        if (assetPath != null) 'asset_path': assetPath,
      };
}

class PaymentPage extends StatefulWidget {
  final int jadwalId;
  final String filmTitle;
  final int customerId;
  final List<int> seatIds;
  final List<Map<String, dynamic>> seatDetails;
  final int totalAmount;
  final Map<String, dynamic>? jadwalInfo;
  final int? studioId;
  final String? studioName;

  const PaymentPage({
    super.key,
    required this.jadwalId,
    required this.filmTitle,
    required this.customerId,
    required this.seatIds,
    required this.seatDetails,
    required this.totalAmount,
    this.jadwalInfo,
    this.studioId,
    this.studioName,
  });

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final api = ApiService();
  late final List<PaymentOption> _options;
  String? _selectedCode;
  bool _submitting = false;
  final _accountNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _options = const [
      PaymentOption(
        code: 'BCA',
        title: 'Transfer Bank BCA',
        description: 'Bank Central Asia',
        icon: Icons.account_balance,
        accountNumber: '031401001122334',
        owner: 'Lotus Cinema',
        extraNote:
            'Pastikan nama rekening pengirim sama dengan data yang Anda isi.',
      ),
      PaymentOption(
        code: 'BRI',
        title: 'Transfer Bank BRI',
        description: 'Bank Rakyat Indonesia',
        icon: Icons.account_balance_wallet,
        accountNumber: '033401001122334',
        owner: 'Lotus Cinema',
        extraNote:
            'Pastikan nama rekening pengirim sama dengan data yang Anda isi.',
      ),
      PaymentOption(
        code: 'QRIS',
        title: 'QRIS Lotus Cinema',
        description: 'Pembayaran instan via QR code',
        icon: Icons.qr_code_2,
        accountNumber: 'ID1023241444042',
        owner: 'Lotus Cinema',
        isQris: true,
        extraNote:
            'Pastikan nama rekening pengirim sama dengan data yang Anda isi.',
        assetPath: 'assets/QRIS.png',
      ),
    ];
    _selectedCode = _options.first.code;
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    super.dispose();
  }

  PaymentOption? get _selectedOption =>
      _options.firstWhere((opt) => opt.code == _selectedCode,
          orElse: () => _options.first);

  String get _seatLabels {
    final labels = widget.seatDetails
        .map((e) => e['nomor_kursi']?.toString())
        .whereType<String>()
        .where((label) => label.trim().isNotEmpty)
        .map((label) => label.trim())
        .toList();
    return labels.isEmpty ? '-' : labels.join(', ');
  }

  String _formatCurrency(int value) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final left = digits.length - i - 1;
      if (left > 0 && left % 3 == 0) buffer.write('.');
    }
    return (value < 0 ? '-' : '') + buffer.toString();
  }

  Future<void> _submitPayment() async {
    final selected = _selectedOption;
    if (selected == null) return;
    final accountName = _accountNameController.text.trim();
    if (accountName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Nama pemilik rekening wajib diisi.'),
      ));
      return;
    }
    setState(() => _submitting = true);
    try {
      final res = await api.checkout(
        customerId: widget.customerId,
        jadwalId: widget.jadwalId,
        kursiIds: widget.seatIds,
        paymentMethod: selected.code,
        paymentDestination: selected.accountNumber,
        paymentAccountName: accountName,
      );

      final pendingPayload = {
        ...res,
        'film_title': widget.filmTitle,
        'studio_name': widget.studioName,
        'studio_id': widget.studioId,
        'jadwal': widget.jadwalInfo,
        'seat_details': widget.seatDetails,
        'seat_labels': _seatLabels,
        'total_harga': widget.totalAmount,
        'payment_option': selected.toJson(),
        'payment_account_name': accountName,
      };

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentPendingPage(data: pendingPayload),
        ),
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal membuat transaksi: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _buildSummaryCard(ColorScheme cs) {
    final jadwalTanggal = widget.jadwalInfo?['tanggal']?.toString();
    final jadwalMulai = widget.jadwalInfo?['jam_mulai']?.toString();
    final jadwalSelesai = widget.jadwalInfo?['jam_selesai']?.toString();
    final studioName = widget.studioName ?? 'Studio ${widget.studioId ?? '-'}';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Pesanan',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            _infoRow('Film', widget.filmTitle, cs),
            _infoRow('Studio', studioName, cs),
            if (jadwalTanggal != null) _infoRow('Tanggal', jadwalTanggal, cs),
            if (jadwalMulai != null)
              _infoRow(
                  'Jam',
                  [jadwalMulai, jadwalSelesai]
                      .whereType<String>()
                      .where((e) => e.isNotEmpty)
                      .join(' - '),
                  cs),
            _infoRow('Kursi', _seatLabels, cs),
            _infoRow('Total', 'Rp ${_formatCurrency(widget.totalAmount)}', cs,
                emphasize: true),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, ColorScheme cs,
      {bool emphasize = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13)),
          ),
          const SizedBox(width: 12),
          Text(
            value.isEmpty ? '-' : value,
            style: TextStyle(
              color: emphasize ? cs.primary : cs.onSurface,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentOptionCard(PaymentOption option, ColorScheme cs) {
    final selected = option.code == _selectedCode;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: selected ? 4 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _selectedCode = option.code),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: cs.primary.withOpacity(.12),
                    child: Icon(option.icon, color: cs.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(option.title,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 15)),
                        Text(option.description,
                            style: TextStyle(color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Radio<String>(
                    value: option.code,
                    groupValue: _selectedCode,
                    onChanged: (v) => setState(() => _selectedCode = v),
                  ),
                ],
              ),
              if (option.extraNote != null) ...[
                const SizedBox(height: 10),
                Text(option.extraNote!,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ],
              const SizedBox(height: 8),
              Text(
                option.isQris
                    ? 'Detail QR akan ditampilkan setelah Anda checkout.'
                    : 'Nomor rekening akan muncul di halaman konfirmasi.',
                style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.background,
      appBar: AppTheme.buildGradientAppBar(context, 'Pembayaran'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
        children: [
          _buildSummaryCard(cs),
          const SizedBox(height: 12),
          Text('Pilih Metode Pembayaran',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ..._options.map((opt) => _paymentOptionCard(opt, cs)),
          const SizedBox(height: 16),
          TextField(
            controller: _accountNameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nama pemilik rekening (wajib)',
              hintText: 'Sesuai buku tabungan / akun bank pengirim',
              helperText:
                  'Harus sama persis dengan nama akun bank yang mentransfer.',
              helperMaxLines: 2,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data ini akan diteruskan ke admin sebagai validasi pembayaran dan wajib diisi.',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton.icon(
            onPressed: _submitting ? null : _submitPayment,
            icon: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_circle),
            label: Text(
                'Konfirmasi Pembayaran • Rp ${_formatCurrency(widget.totalAmount)}'),
          ),
        ),
      ),
    );
  }
}
