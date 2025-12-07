import 'package:flutter/material.dart';
import '../api_service.dart';
import '../theme/app_theme.dart';
import 'film_form_page.dart';
import 'film_detail_page.dart';

class FilmListPage extends StatefulWidget {
  const FilmListPage({super.key});

  @override
  State<FilmListPage> createState() => _FilmListPageState();
}

class _FilmListPageState extends State<FilmListPage> {
  final api = ApiService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
    _load();
  }

  Future<void> _loadRole() async {
    final r = await api.getStoredRole();
    if (!mounted) return;
    setState(() => _isAdmin = (r == 'admin'));
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await api.films(perPage: 200);
      final list = res.data
          .map((e) => e is Map
              ? Map<String, dynamic>.from(e as Map)
              : <String, dynamic>{})
          .where((m) => m.isNotEmpty)
          .toList();
      setState(() => _items = list);
    } catch (e) {
      setState(() => _error = 'Gagal memuat film: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  dynamic _filmIdOf(Map<String, dynamic> m) {
    final raw = m['film_id'] ?? m['id'] ?? m['ID'];
    if (raw is int) return raw;
    return int.tryParse('$raw');
  }

  String _titleOf(Map<String, dynamic> m) {
    return (m['judul'] ?? m['title'] ?? 'Tanpa Judul').toString();
  }

  String _durationOf(Map<String, dynamic> m) {
    final raw = m['durasi'];
    if (raw == null) return '-';
    final parsed = int.tryParse(raw.toString());
    return parsed == null ? raw.toString() : parsed.toString();
  }

  String _genreLabel(Map<String, dynamic> m) {
    final g = (m['genre_name'] ?? m['genre_nama'] ?? m['genre'])?.toString();
    if (g != null && g.isNotEmpty) return g;
    final id = m['genre_id'] ?? m['id_genre'];
    return id == null ? '-' : 'ID $id';
  }

  String _sanitizeUrl(String? raw) {
    if (raw == null) return '';
    var value = raw.trim();
    if (value.isEmpty) return '';
    value = value.replaceAllMapped(RegExp(r':(\d+):\1'), (m) => ':${m[1]}');
    value = value.replaceAll(RegExp(r'(?<=https?:\/\/)(\/{2,})'), '/');
    return value;
  }

  int _gridCountForWidth(double width) {
    if (width < 360) return 1;
    if (width < 600) return 2;
    if (width < 900) return 3;
    if (width < 1200) return 4;
    return 5;
  }

  double _childAspectRatioForWidth(double width) {
    // Buat kartu adaptif: layar lebar tetap punya ruang ekstra di bawah poster
    // sehingga teks tidak overflow saat poster mengecil.
    if (width >= 1200) return 0.52;
    if (width >= 900) return 0.54;
    if (width >= 600) return 0.56;
    if (width >= 360) return 0.5;
    return 0.46;
  }

  /// Samakan cara resolving poster dengan halaman detail
  String? _posterUrl(Map<String, dynamic> film) {
    for (final key in [
      'poster_asset_url',
      'poster_url',
      'poster',
      'poster_path',
    ]) {
      final resolved = api.resolvePosterUrl(film[key]?.toString());
      if (resolved != null) {
        final sanitized = _sanitizeUrl(resolved);
        if (sanitized.isNotEmpty) return sanitized;
      }
    }
    return null;
  }

  Widget _posterContent(Map<String, dynamic> film) {
    final url = _posterUrl(film);

    Widget placeholder(Color color, IconData icon) => Container(
          color: color,
          child: Icon(icon, size: 48, color: Colors.black45),
        );

    Widget content;
    if (url == null) {
      content = placeholder(Colors.black12, Icons.movie_creation_outlined);
    } else {
      content = Image.network(
        url,
        fit: BoxFit.cover, // Memenuhi area
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (ctx, child, progress) => progress == null
            ? child
            : placeholder(Colors.grey.shade200, Icons.image_outlined),
        errorBuilder: (_, __, ___) =>
            placeholder(Colors.black12, Icons.movie_creation_outlined),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        content,
        // Tombol Admin (Edit & Hapus)
        if (_isAdmin)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBtn(Icons.edit, () => _edit(film)),
                  Container(
                    width: 1,
                    height: 16,
                    color: Colors.white30,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                  ),
                  _iconBtn(Icons.delete_outline, () => _delete(film),
                      isDestructive: true),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: isDestructive ? Colors.redAccent : Colors.white,
        ),
      ),
    );
  }

  Future<void> _create() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => FilmFormPage()),
    );
    if (saved == true) _load();
  }

  Future<void> _edit(Map<String, dynamic> film) async {
    final id = _filmIdOf(film);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID film tidak valid')),
      );
      return;
    }
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FilmFormPage(
          filmId: id as int,
          initial: Map<String, dynamic>.from(film),
        ),
      ),
    );
    if (saved == true) _load();
  }

  Future<void> _delete(Map<String, dynamic> film) async {
    final id = _filmIdOf(film);
    if (id == null) return;
    final sure = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Hapus Film'),
            content: Text('Yakin ingin menghapus "${_titleOf(film)}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Hapus'),
              ),
            ],
          ),
        ) ??
        false;

    if (!sure) return;

    try {
      await api.deleteFilm(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Film dihapus')),
      );
      _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppTheme.buildGradientAppBar(
        context,
        'Daftar Film',
      ),
      floatingActionButton: _isAdmin
          ? FloatingActionButton.extended(
              onPressed: _create,
              icon: const Icon(Icons.add),
              label: const Text('Tambah'),
            )
          : null,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _items.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 48),
                          children: [
                            const Icon(Icons.movie_filter_outlined, size: 72),
                            const SizedBox(height: 16),
                            const Text(
                              'Belum ada film yang terdaftar.',
                              textAlign: TextAlign.center,
                            ),
                            if (_isAdmin) ...[
                              const SizedBox(height: 16),
                              FilledButton.icon(
                                onPressed: _create,
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Film'),
                              ),
                            ],
                          ],
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final count = _gridCountForWidth(width);
                            final aspect = _childAspectRatioForWidth(width);

                            return GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(12, 12, 12, 96),
                              itemCount: _items.length,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: count,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: aspect,
                              ),
                              itemBuilder: (context, i) {
                                final film = _items[i];
                                final id = _filmIdOf(film);

                                return Card(
                                  clipBehavior: Clip
                                      .antiAlias, // Kunci: Memotong gambar agar rounded mengikuti card
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 3,
                                  shadowColor: Colors.black26,
                                  child: InkWell(
                                    onTap: id == null
                                        ? null
                                        : () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => FilmDetailPage(
                                                  filmId: id as int,
                                                  initial: film,
                                                ),
                                              ),
                                            ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // POSTER AREA (masih dominan tapi memberi ruang teks)
                                        Expanded(
                                          flex: 4,
                                          child: _posterContent(film),
                                        ),
                                        // TEXT AREA (dibuat lebih lega agar tidak overflow)
                                        Expanded(
                                          flex: 2,
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                // Judul
                                                Text(
                                                  _titleOf(film),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        height: 1.2,
                                                      ),
                                                ),
                                                const SizedBox(height: 4),
                                                // Info Tambahan
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _genreLabel(film),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.white[600],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Icon(Icons.schedule,
                                                        size: 12,
                                                        color:
                                                            Colors.white[600]),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        '${_durationOf(film)} m',
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.white[600],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),
    );
  }
}

extension on Color {
  Color? operator [](int other) {}
}
