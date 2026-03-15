import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../data/repositories/ai_cache_repository.dart';

final macroContextServiceProvider = Provider<MacroContextService>((ref) {
  return MacroContextService();
});

class MacroContextService {
  static const String _cacheKey = 'macro_context_live_v1';
  static const int _cacheTtlMinutes = 120;
  static const int _maxHeadlines = 8;
  static const Duration _requestTimeout = Duration(seconds: 8);

  final AiCacheRepository _cacheRepo;
  final http.Client _httpClient;

  MacroContextService({AiCacheRepository? cacheRepo, http.Client? httpClient})
    : _cacheRepo = cacheRepo ?? AiCacheRepository(),
      _httpClient = httpClient ?? http.Client();

  Future<MacroContextSnapshot?> fetchLatest({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cacheRepo.getCachedResponse(_cacheKey);
      if (cached != null) {
        final parsed = MacroContextSnapshot.tryFromJson(
          cached,
          fromCache: true,
        );
        if (parsed != null) return parsed;
      }
    }

    final merged = <MacroHeadline>[];
    for (final query in _queries) {
      merged.addAll(await _fetchFromGdelt(query));
    }

    final dedupedByUrl = <String, MacroHeadline>{};
    for (final headline in merged) {
      dedupedByUrl.putIfAbsent(headline.url, () => headline);
    }

    final sorted = dedupedByUrl.values.toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
    final top = sorted.take(_maxHeadlines).toList();
    if (top.isEmpty) return null;

    final snapshot = MacroContextSnapshot(
      fetchedAt: DateTime.now().toUtc(),
      headlines: top,
      fromCache: false,
    );

    await _cacheRepo.cacheResponse(
      _cacheKey,
      jsonEncode(snapshot.toJson()),
      ttlMinutes: _cacheTtlMinutes,
    );

    return snapshot;
  }

  Future<List<MacroHeadline>> _fetchFromGdelt(String query) async {
    final uri = Uri.parse(
      'https://api.gdeltproject.org/api/v2/doc/doc'
      '?query=${Uri.encodeQueryComponent(query)}'
      '&mode=ArtList'
      '&maxrecords=8'
      '&format=json'
      '&sort=DateDesc',
    );

    try {
      final response = await _httpClient
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_requestTimeout);
      if (response.statusCode != 200) {
        return [];
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        return [];
      }

      final articles = decoded['articles'];
      if (articles is! List) {
        return [];
      }

      return articles
          .map(
            (raw) =>
                MacroHeadline.tryFromMap(raw, theme: _themeForQuery(query)),
          )
          .whereType<MacroHeadline>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  String _themeForQuery(String query) {
    if (query.contains('election') ||
        query.contains('war') ||
        query.contains('geopolitics') ||
        query.contains('trade war')) {
      return 'geopolitics';
    }
    return 'macro';
  }

  static const List<String> _queries = [
    '(interest rate OR inflation OR recession OR central bank OR tariff OR sanctions OR "oil price" OR "bond yield") sourcelang:english',
    '(election OR war OR conflict OR geopolitics OR embargo OR "trade war") (economy OR market OR inflation) sourcelang:english',
  ];
}

class MacroContextSnapshot {
  final DateTime fetchedAt;
  final List<MacroHeadline> headlines;
  final bool fromCache;

  MacroContextSnapshot({
    required this.fetchedAt,
    required this.headlines,
    required this.fromCache,
  });

  String toPromptBlock({int maxItems = 6}) {
    final limited = headlines.take(maxItems).toList();
    if (limited.isEmpty) {
      return 'GLOBAL MACRO UPDATE: data tidak tersedia.';
    }

    final items = limited
        .map(
          (h) =>
              '- [${h.dateKey}] ${h.title} (${h.domain}, ${h.sourceCountry}) '
              '[${h.theme}] | ${h.url}',
        )
        .join('\n');

    return '''GLOBAL MACRO UPDATE (sumber live, fetch UTC ${_fmtUtc(fetchedAt)}):
$items''';
  }

  Map<String, Object?> toJson() => {
    'fetchedAt': fetchedAt.toIso8601String(),
    'fromCache': fromCache,
    'headlines': headlines.map((h) => h.toJson()).toList(),
  };

  static MacroContextSnapshot? tryFromJson(
    String raw, {
    bool fromCache = false,
  }) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final fetchedAtRaw = decoded['fetchedAt']?.toString();
      final fetchedAt = DateTime.tryParse(fetchedAtRaw ?? '')?.toUtc();
      final headlinesRaw = decoded['headlines'];
      if (fetchedAt == null || headlinesRaw is! List) {
        return null;
      }

      final headlines = headlinesRaw
          .map((e) => MacroHeadline.tryFromMap(e, theme: null))
          .whereType<MacroHeadline>()
          .toList();
      if (headlines.isEmpty) return null;

      return MacroContextSnapshot(
        fetchedAt: fetchedAt,
        headlines: headlines,
        fromCache: fromCache,
      );
    } catch (_) {
      return null;
    }
  }

  static String _fmtUtc(DateTime dt) {
    final utc = dt.toUtc();
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    final hh = utc.hour.toString().padLeft(2, '0');
    final mm = utc.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }
}

class MacroHeadline {
  final String title;
  final String url;
  final String domain;
  final String sourceCountry;
  final DateTime publishedAt;
  final String theme;

  MacroHeadline({
    required this.title,
    required this.url,
    required this.domain,
    required this.sourceCountry,
    required this.publishedAt,
    required this.theme,
  });

  String get dateKey {
    final utc = publishedAt.toUtc();
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Map<String, Object?> toJson() => {
    'title': title,
    'url': url,
    'domain': domain,
    'sourceCountry': sourceCountry,
    'publishedAt': publishedAt.toIso8601String(),
    'theme': theme,
  };

  static MacroHeadline? tryFromMap(Object? raw, {required String? theme}) {
    if (raw is! Map) return null;

    final title = _clean(raw['title']?.toString() ?? '');
    final url = (raw['url']?.toString() ?? '').trim();
    if (title.isEmpty || url.isEmpty) return null;

    final domain = _clean(raw['domain']?.toString() ?? 'unknown');
    final sourceCountry = _clean(raw['sourcecountry']?.toString() ?? 'Unknown');
    final seenDate = raw['seendate']?.toString();
    final publishedAt = _parseSeenDate(seenDate);
    final resolvedTheme = (theme ?? raw['theme']?.toString() ?? 'macro').trim();

    return MacroHeadline(
      title: title,
      url: url,
      domain: domain,
      sourceCountry: sourceCountry,
      publishedAt: publishedAt,
      theme: resolvedTheme.isEmpty ? 'macro' : resolvedTheme,
    );
  }

  static DateTime _parseSeenDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return DateTime.now().toUtc();
    }

    final compact = raw.trim();
    if (compact.length >= 16 && compact.contains('T')) {
      try {
        final iso =
            '${compact.substring(0, 4)}-${compact.substring(4, 6)}-${compact.substring(6, 8)}'
            'T${compact.substring(9, 11)}:${compact.substring(11, 13)}:${compact.substring(13, 15)}Z';
        final parsed = DateTime.tryParse(iso);
        if (parsed != null) return parsed.toUtc();
      } catch (_) {}
    }

    return DateTime.tryParse(compact)?.toUtc() ?? DateTime.now().toUtc();
  }

  static String _clean(String input) {
    return input
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
