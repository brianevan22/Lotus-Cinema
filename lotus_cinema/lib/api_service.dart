import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  final dynamic data;
  ApiException(this.message, {this.status, this.data});
  @override
  String toString() => 'ApiException($status): $message';
}

class PaginatedResponse {
  final List<dynamic> data;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginatedResponse({
    required this.data,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginatedResponse.from(dynamic json) {
    if (json is Map &&
        json.containsKey('data') &&
        json.containsKey('current_page')) {
      return PaginatedResponse(
        data: (json['data'] as List?) ?? const [],
        currentPage: json['current_page'] ?? 1,
        lastPage: json['last_page'] ?? 1,
        perPage: json['per_page'] is int
            ? json['per_page']
            : int.tryParse('${json['per_page'] ?? 10}') ?? 10,
        total: json['total'] ??
            (json['data'] is List ? (json['data'] as List).length : 0),
      );
    }
    final list = (json is List)
        ? json
        : (json is Map && json['data'] is List
            ? (json['data'] as List)
            : <dynamic>[]);
    return PaginatedResponse(
      data: list,
      currentPage: 1,
      lastPage: 1,
      perPage: list.length,
      total: list.length,
    );
  }
}

class ApiService {
  late final Dio _dio;
  final String baseUrl;
  late final String _effectiveBaseUrl;

  static const _defaultBackend = 'http://127.0.0.1:8000';

  static String suggestBaseUrl() {
    if (kIsWeb) return _defaultBackend;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _defaultBackend;
    }
    return _defaultBackend;
  }

  static String _normalizeBaseUrl(String raw) {
    var value = raw.trim();
    if (!value.contains('://')) value = 'http://$value';
    final uri = Uri.parse(value);
    final isAndroidDevice =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (isAndroidDevice &&
        (uri.host == '127.0.0.1' || uri.host.toLowerCase() == 'localhost')) {
      return uri.replace(host: '10.0.2.2').toString();
    }
    return value;
  }

  ApiService({String? base})
      : baseUrl = base ?? suggestBaseUrl(),
        _dio = Dio(BaseOptions(
          baseUrl: '${suggestBaseUrl()}/api',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
        )) {
    _effectiveBaseUrl = _normalizeBaseUrl(baseUrl);

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await getStoredToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (err, handler) => handler.next(err),
    ));
  }

  // ===== TOKEN STORAGE =====
  static const _tokenKey = 'auth_token';
  static const _roleKey = 'auth_role';
  static const _customerKey = 'auth_customer_id';
  static const _userIdKey = 'auth_user_id';

  Future<String?> getStoredRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  Future<void> setRole(String? role) async {
    final prefs = await SharedPreferences.getInstance();
    if (role != null) {
      await prefs.setString(_roleKey, role);
    } else {
      await prefs.remove(_roleKey);
    }
  }

  Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> setToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(_tokenKey, token);
    } else {
      await prefs.remove(_tokenKey);
    }
  }

  Future<int?> getStoredCustomerId() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_customerKey);
    return v;
  }

  Future<void> setCustomerId(int? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setInt(_customerKey, id);
    } else {
      await prefs.remove(_customerKey);
    }
  }

  Future<int?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getInt(_userIdKey);
    return v;
  }

  Future<void> setUserId(int? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) {
      await prefs.setInt(_userIdKey, id);
    } else {
      await prefs.remove(_userIdKey);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {}
    await setToken(null);
    await setRole(null);
    // pastikan juga hapus stored user/customer id saat logout
    await setUserId(null);
    await setCustomerId(null);
  }

  int? _coerceInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  Future<void> _persistAuthPayload(
    Map<String, dynamic> payload, {
    String fallbackRole = 'customer',
  }) async {
    final tokenStr =
        (payload['token'] ?? payload['api_token'] ?? '').toString().trim();
    await setToken(tokenStr.isEmpty ? null : tokenStr);

    final role = _extractRole(payload, fallback: fallbackRole);
    await setRole(role);

    final userMap = payload['user'];
    final userId = userMap is Map
        ? _coerceInt(userMap['id'])
        : _coerceInt(payload['user_id'] ?? payload['id']);
    await setUserId(userId);

    var customerId = _coerceInt(payload['customer_id']);
    if (customerId == null) {
      if (role == 'customer' && userMap is Map) {
        customerId = _coerceInt(userMap['customer_id'] ?? userMap['id']);
      }
      final custMap = payload['customer'];
      if (customerId == null && custMap is Map) {
        customerId = _coerceInt(custMap['id'] ?? custMap['customer_id']);
      }
    }
    await setCustomerId(customerId);
  }

  // ===== AUTH =====
  Future<Map<String, dynamic>> register(
    String username,
    String password, {
    required String name,
    required String email,
    required String noHp,
  }) async {
    try {
      final res = await _dio.post('/auth/register', data: {
        'username': username,
        'password': password,
        'name': name,
        'email': email,
        'no_hp': noHp,
      });
      final payload = _toMap(res.data);
      await setRole(null);
      return payload;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      final payload = _toMap(res.data);
      await _persistAuthPayload(
        payload,
        fallbackRole: username == 'admin' ? 'admin' : 'customer',
      );
      final token = await getStoredToken();
      final role = await getStoredRole() ?? 'customer';
      return {'token': token, 'role': role, 'raw': payload};
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // ===== FILM =====
  Future<PaginatedResponse> films(
      {int page = 1, int perPage = 50, String? search}) async {
    final query = <String, dynamic>{
      'flat': 1,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    try {
      final res = await _dio.get('/film', queryParameters: query);
      return PaginatedResponse.from(_normalizeFilmPayload(res.data));
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Map<String, dynamic>> filmDetail(dynamic id) async {
    try {
      final res = await _dio.get('/film/$id');
      return _toMap(res.data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Map<String, dynamic>> createFilm(Map<String, dynamic> body) async {
    try {
      final res = await _dio.post('/film', data: body);
      return _toMap(res.data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // ✅ Update film
  Future<Map<String, dynamic>> updateFilm(
      int id, Map<String, dynamic> body) async {
    try {
      final res = await _dio.put('/film/$id', data: body);
      return _toMap(res.data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  /// Hapus film — default force=true (hapus relasi terkait)
  Future<void> deleteFilm(dynamic id, {bool force = true}) async {
    try {
      await _dio.delete('/film/$id', queryParameters: {'force': force ? 1 : 0});
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // ===== JADWAL (tambahan CRUD front-end) =====
  Future<List<Map<String, dynamic>>> jadwalList({int? filmId}) async {
    final qp = <String, dynamic>{if (filmId != null) 'film_id': filmId};
    final res = await _dio.get('/jadwal', queryParameters: qp);
    final raw = res.data;
    final list = (raw is List)
        ? raw
        : (raw is Map && raw['data'] is List ? raw['data'] : const []);
    return list
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<Map<String, dynamic>> jadwalShow(int id) async {
    final res = await _dio.get('/jadwal/$id');
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> jadwalCreate({
    required int filmId,
    required int studioId,
    required String tanggal, // 'YYYY-MM-DD'
    required String jamMulai, // 'HH:mm:ss'
    required String jamSelesai, // 'HH:mm:ss'
  }) async {
    final res = await _dio.post('/jadwal', data: {
      'film_id': filmId,
      'studio_id': studioId,
      'tanggal': tanggal,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  Future<Map<String, dynamic>> jadwalUpdate(
    int id, {
    required int filmId,
    required int studioId,
    required String tanggal,
    required String jamMulai,
    required String jamSelesai,
  }) async {
    final res = await _dio.put('/jadwal/$id', data: {
      'film_id': filmId,
      'studio_id': studioId,
      'tanggal': tanggal,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
    });
    return Map<String, dynamic>.from(res.data as Map);
  }

  /// Hapus jadwal — default force=true (hapus tiket & detail-transaksi terkait)
  Future<void> jadwalDelete(int id, {bool force = true}) async {
    try {
      await _dio
          .delete('/jadwal/$id', queryParameters: {'force': force ? 1 : 0});
    } on DioException catch (e) {
      final status = e.response?.statusCode ?? 0;
      final shouldRetry = status == 301 || status == 302 || status == 405;
      if (shouldRetry) {
        try {
          await _dio.post(
            '/jadwal/$id',
            data: {
              '_method': 'DELETE',
              'force': force ? 1 : 0,
            },
          );
          return;
        } on DioException catch (inner) {
          throw _wrap(inner);
        }
      }
      throw _wrap(e);
    }
  }

  // ===== STUDIO LIST =====
  Future<List<Map<String, dynamic>>> studiosList() async {
    Future<Response> _try(String path) => _dio.get(path);

    Response res;
    try {
      res = await _try('/studio');
    } on DioException {
      res = await _try('/studios'); // fallback
    }

    final raw = res.data;
    final list = (raw is List)
        ? raw
        : (raw is Map && raw['data'] is List ? raw['data'] : const []);
    return list.map<Map<String, dynamic>>((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final rawId = m['studio_id'] ?? m['id'];
      final id = rawId is int ? rawId : int.tryParse('$rawId') ?? -1;
      final nama = (m['nama_studio'] ?? m['nama'] ?? m['name'] ?? 'Studio $id')
          .toString();
      return {'id': id, 'nama': nama, ...m};
    }).toList();
  }

  // ===== JADWAL (lama) – by film untuk seat selection =====
  Future<List<dynamic>> jadwalByFilm(int filmId) async {
    try {
      final res = await _dio.get('/jadwal/by-film/$filmId');
      final d = res.data;
      if (d is List) return d;
      if (d is Map && d['data'] is List) return d['data'];
      return <dynamic>[];
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // ===== SEATS =====
  Future<List<dynamic>> seatsAvailable(int jadwalId) async {
    try {
      final res = await _dio.get('/jadwal/$jadwalId/seats');

      final raw = (res.data is List)
          ? (res.data as List)
          : (res.data is Map && res.data['data'] is List
              ? (res.data['data'] as List)
              : const <dynamic>[]);

      final normalized = raw.map((e) {
        final m = Map<String, dynamic>.from(e as Map);

        num hargaNum;
        final v = m['harga'];
        if (v is num) {
          hargaNum = v;
        } else {
          final asInt = int.tryParse('$v');
          if (asInt != null) {
            hargaNum = asInt;
          } else {
            final asDouble = double.tryParse('$v');
            hargaNum = asDouble?.round() ?? 0;
          }
        }

        if ((hargaNum == 0) && m.containsKey('price')) {
          final pv = m['price'];
          if (pv is num)
            hargaNum = pv;
          else {
            final pi =
                int.tryParse('$pv') ?? (double.tryParse('$pv')?.round() ?? 0);
            hargaNum = pi;
          }
        }

        m['harga'] = hargaNum;
        m['price'] = hargaNum;
        m['harga_int'] = hargaNum;

        final st = (m['status'] ?? 'tersedia').toString().toLowerCase();
        m['status'] =
            (st == 'sold' || st == 'terjual') ? 'terjual' : 'tersedia';

        return m;
      }).toList();

      return normalized;
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // ===== CHECKOUT =====
  Future<Map<String, dynamic>> checkout({
    int? customerId,
    required int jadwalId,
    required List<int> kursiIds,
    int? kasirId,
    String? paymentMethod,
    String? paymentDestination,
    required String paymentAccountName,
  }) async {
    final resolvedCustomer = customerId ?? await getStoredCustomerId();
    if (resolvedCustomer == null) {
      throw ApiException(
        'Customer ID tidak ditemukan. Silakan login ulang sebelum checkout.',
        status: 422,
      );
    }
    try {
      final now = DateTime.now();
      final res = await _dio.post('/checkout', data: {
        'customer_id': resolvedCustomer,
        'jadwal_id': jadwalId,
        'kursi_ids': kursiIds,
        if (kasirId != null) 'kasir_id': kasirId,
        'client_time': now.toIso8601String(),
        'client_tz': now.timeZoneName,
        if (paymentMethod != null && paymentMethod.isNotEmpty)
          'payment_method': paymentMethod,
        if (paymentDestination != null && paymentDestination.isNotEmpty)
          'payment_destination': paymentDestination,
        'payment_account_name': paymentAccountName,
      });
      return _toMap(res.data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<PaginatedResponse> transactions({
    int page = 1,
    int perPage = 50,
    String? status,
    int? customerId,
    bool onlyPending = false,
  }) async {
    final qp = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (status != null && status.isNotEmpty) 'status': status,
      if (customerId != null) 'customer_id': customerId,
      if (onlyPending) 'only_pending': 1,
    };
    try {
      final res = await _dio.get('/transaksi', queryParameters: qp);
      return PaginatedResponse.from(res.data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Map<String, dynamic>> transactionDetail(int id) async {
    try {
      final res = await _dio.get('/transaksi/$id');
      return _unwrapResourceMap(res.data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Map<String, dynamic>> updateTransactionStatus(
      int id, String status) async {
    Future<Map<String, dynamic>> _sendPatch() async {
      final res = await _dio.patch('/transaksi/$id/status', data: {
        'status': status,
      });
      return _unwrapResourceMap(res.data);
    }

    try {
      return await _sendPatch();
    } on DioException catch (e) {
      final shouldRetry = e.type == DioExceptionType.badResponse &&
          (e.response?.statusCode == 405 || e.response?.statusCode == 404);
      final connectionIssue = e.type == DioExceptionType.unknown ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError;
      if (!(shouldRetry || connectionIssue)) {
        throw _wrap(e);
      }
      try {
        final res = await _dio.post('/transaksi/$id/status', data: {
          'status': status,
          '_method': 'PATCH',
        });
        return _unwrapResourceMap(res.data);
      } on DioException catch (inner) {
        throw _wrap(inner);
      }
    }
  }

  Map<String, dynamic> buildTicketPayloadFromTransaction(
      Map<String, dynamic> trx) {
    final kursiList = (trx['kursi'] is List)
        ? List<Map<String, dynamic>>.from(
            (trx['kursi'] as List)
                .map((e) => e is Map ? Map<String, dynamic>.from(e) : null)
                .whereType<Map<String, dynamic>>(),
          )
        : <Map<String, dynamic>>[];
    final kursiLabels = kursiList
        .map((e) => e['nomor_kursi']?.toString())
        .whereType<String>()
        .where((label) => label.trim().isNotEmpty)
        .map((label) => label.trim())
        .toList();

    final jadwal = trx['jadwal'] is Map
        ? Map<String, dynamic>.from(trx['jadwal'] as Map)
        : <String, dynamic>{};
    final studio = jadwal['studio'] is Map
        ? Map<String, dynamic>.from(jadwal['studio'] as Map)
        : <String, dynamic>{};
    final film = trx['film'] is Map
        ? Map<String, dynamic>.from(trx['film'] as Map)
        : <String, dynamic>{};

    return {
      'transaksi_id': trx['transaksi_id'],
      'film_title': film['judul'] ?? trx['film_title'] ?? '-',
      'studio_name':
          studio['nama_studio'] ?? 'Studio ${studio['studio_id'] ?? '-'}',
      'studio_id': studio['studio_id'],
      'jadwal_tanggal': jadwal['tanggal'],
      'jadwal_mulai': jadwal['jam_mulai'],
      'jadwal_selesai': jadwal['jam_selesai'],
      'kursi': kursiList,
      'kursi_labels': kursiLabels.join(', '),
      'total_harga': trx['total_harga'],
      'purchase_time': trx['paid_at'] ?? trx['tanggal_transaksi'],
      'project_name': 'Lotus Cinema',
      'status': trx['status'],
    };
  }

  // ===== GENRES =====
  Future<List<Map<String, dynamic>>> genresList() async {
    Future<Response<dynamic>> _fetch(String path) => _dio.get(path);
    Response<dynamic> res;
    try {
      res = await _fetch('/genre');
    } on DioException {
      res = await _fetch('/genres');
    }

    final raw = res.data;
    final list = raw is List
        ? raw
        : (raw is Map && raw['data'] is List ? raw['data'] as List : const []);
    return list
        .map((e) =>
            e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{})
        .where((m) => (m['id'] ?? m['genre_id'] ?? m['id_genre']) != null)
        .map((m) {
      final rawId = m['id'] ?? m['genre_id'] ?? m['id_genre'];
      final id = rawId is int ? rawId : int.tryParse('$rawId') ?? -1;
      final nama =
          (m['nama'] ?? m['nama_genre'] ?? m['name'] ?? m['judul'] ?? '')
              .toString();
      return {'id': id, 'nama': nama, ...m};
    }).toList();
  }

  Map<int, String>? _genreCache;

  Future<Map<int, String>> _ensureGenres() async {
    if (_genreCache != null) return _genreCache!;
    final map = <int, String>{};
    try {
      final res = await _dio.get('/genres');
      final list = (res.data is List)
          ? (res.data as List)
          : (res.data is Map && res.data['data'] is List
              ? res.data['data'] as List
              : const <dynamic>[]);

      for (final it in list) {
        final m = _toMap(it);
        final rawId = m['id_genre'] ?? m['genre_id'] ?? m['id'];
        final name =
            (m['nama'] ?? m['nama_genre'] ?? m['name'] ?? m['judul'] ?? '')
                .toString();
        final id = rawId is int ? rawId : int.tryParse('$rawId');
        if (id != null && name.isNotEmpty) {
          map[id] = name;
        }
      }
    } catch (_) {}
    _genreCache = map;
    return map;
  }

  Future<String?> genreNameById(int? id) async {
    if (id == null) return null;

    try {
      final map = await _ensureGenres();
      final fromCache = map[id];
      if (fromCache != null && fromCache.isNotEmpty) return fromCache;
    } catch (_) {}

    try {
      final res = await _dio.get('/genres/$id');
      final m = _toMap(res.data);
      final name =
          (m['nama'] ?? m['nama_genre'] ?? m['name'] ?? m['judul'])?.toString();
      if (name != null && name.isNotEmpty) {
        _genreCache ??= {};
        _genreCache![id] = name;
        return name;
      }
    } catch (_) {}
    return null;
  }

  // ===== COMMENTS =====
  Future<List<Map<String, dynamic>>> commentsList(int filmId,
      {String sort = 'newest'}) async {
    try {
      final res = await _dio
          .get('/komentar', queryParameters: {'film_id': filmId, 'sort': sort});
      final raw = res.data;
      final list = (raw is List)
          ? raw
          : (raw is Map && raw['data'] is List ? raw['data'] : const []);
      return (list as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Map<String, dynamic>> postComment(
      {required int filmId, required String isi, int? rating}) async {
    try {
      final res = await _dio.post('/komentar', data: {
        'film_id': filmId,
        'isi_komentar': isi,
        if (rating != null) 'rating': rating,
      });
      return _toMap(res.data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<Map<String, dynamic>> updateComment(
      {required int id, required String isi, int? rating}) async {
    try {
      final res = await _dio.put('/komentar/$id', data: {
        'isi_komentar': isi,
        if (rating != null) 'rating': rating,
      });
      return _toMap(res.data);
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  Future<void> deleteComment(int id) async {
    try {
      await _dio.delete('/komentar/$id');
    } on DioException catch (e) {
      throw _wrap(e);
    }
  }

  // ===== Utils =====
  ApiException _wrap(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    final msg = (data is Map && data['message'] is String)
        ? data['message']
        : e.message ?? 'Request error';
    return ApiException(msg, status: status, data: data);
  }

  Map<String, dynamic> _toMap(dynamic d) {
    if (d is Map<String, dynamic>) return d;
    if (d is Map) return Map<String, dynamic>.from(d);

    if (d is String) {
      final raw = d.trim();
      if (raw.isEmpty) return <String, dynamic>{};
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
        if (decoded is List) return {'data': decoded};
      } catch (_) {
        // keep fallback below
      }
      return {'message': raw};
    }

    if (d is List) {
      return {'data': d};
    }

    if (d == null) return <String, dynamic>{};
    return {'value': d};
  }

  Map<String, dynamic> _unwrapResourceMap(dynamic payload) {
    final map = _toMap(payload);
    final data = map['data'];
    if (data is Map<String, dynamic>) return Map<String, dynamic>.from(data);
    if (data is Map) return Map<String, dynamic>.from(data);
    return map;
  }

  String _extractRole(Map<String, dynamic> payload,
      {String fallback = 'customer'}) {
    final direct = payload['role'];
    if (direct is String && direct.isNotEmpty) return direct;
    final user = payload['user'];
    if (user is Map) {
      final userMap = _toMap(user);
      final userRole = userMap['role'];
      if (userRole is String && userRole.isNotEmpty) return userRole;
    }
    return fallback;
  }

  String _baseOrigin() {
    final uri = Uri.parse(_effectiveBaseUrl);
    final port = (uri.hasPort && uri.port != 80 && uri.port != 443)
        ? ':${uri.port}'
        : '';
    return '${uri.scheme}://${uri.host}$port';
  }

  String? resolvePosterUrl(String? rawPath) {
    if (rawPath == null) return null;
    var path = rawPath.trim().replaceAll('\\', '/');
    if (path.isEmpty) return null;
    final baseOrigin = _baseOrigin();

    const localhostAliases = [
      'http://127.0.0.1',
      'https://127.0.0.1',
      'http://localhost',
      'https://localhost',
    ];
    for (final alias in localhostAliases) {
      if (path.startsWith(alias)) {
        return path.replaceFirst(alias, baseOrigin);
      }
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final lower = path.toLowerCase();
    if (lower.startsWith('public/poster/')) {
      path = 'storage/' + path.substring('public/'.length);
    } else if (lower.startsWith('poster/')) {
      path = 'storage/' + path;
    } else if (!path.contains('/')) {
      path = 'storage/poster/$path';
    } else if (!lower.startsWith('storage/poster/')) {
      path = 'storage/$path';
    }

    if (path.startsWith('assets/')) {
      return path;
    }
    if (path.startsWith('/')) path = path.substring(1);
    return '$baseOrigin/$path';
  }

  Map<String, dynamic> _normalizeFilmPayload(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw.containsKey('data')) return raw;
      if (raw.containsKey('ok') && raw['data'] is List) {
        final list = List<Map<String, dynamic>>.from(raw['data'] as List);
        return {
          'data': list,
          'total': list.length,
          'per_page': list.length,
          'current_page': 1,
          'last_page': 1,
        };
      }
    }
    if (raw is List) {
      final list = List<Map<String, dynamic>>.from(raw);
      return {
        'data': list,
        'total': list.length,
        'per_page': list.length,
        'current_page': 1,
        'last_page': 1,
      };
    }
    return {
      'data': const <Map<String, dynamic>>[],
      'total': 0,
      'per_page': 0,
      'current_page': 1,
      'last_page': 1,
    };
  }
}
