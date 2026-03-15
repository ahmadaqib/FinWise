import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String defaultDailyLimitStrategy = 'balanced';

class DailyLimitStrategyPreset {
  final String key;
  final String label;
  final double factor;
  final String riskLabel;
  final String riskDescription;

  const DailyLimitStrategyPreset({
    required this.key,
    required this.label,
    required this.factor,
    required this.riskLabel,
    required this.riskDescription,
  });
}

const Map<String, DailyLimitStrategyPreset> dailyLimitStrategyPresets = {
  'conservative': DailyLimitStrategyPreset(
    key: 'conservative',
    label: 'Konservatif',
    factor: 0.8,
    riskLabel: 'Risiko rendah',
    riskDescription:
        'Budget harian lebih ketat; aman untuk kontrol, tapi bisa terasa membatasi.',
  ),
  'balanced': DailyLimitStrategyPreset(
    key: 'balanced',
    label: 'Seimbang',
    factor: 1.0,
    riskLabel: 'Risiko sedang',
    riskDescription:
        'Mengikuti perhitungan engine asli; paling stabil untuk mayoritas kondisi.',
  ),
  'flexible': DailyLimitStrategyPreset(
    key: 'flexible',
    label: 'Fleksibel',
    factor: 1.15,
    riskLabel: 'Risiko lebih tinggi',
    riskDescription:
        'Budget harian lebih longgar; nyaman jangka pendek, tapi rawan overspending.',
  ),
};

DailyLimitStrategyPreset resolveDailyLimitStrategyPreset(String? key) {
  final normalized = (key ?? '').toLowerCase();
  return dailyLimitStrategyPresets[normalized] ??
      dailyLimitStrategyPresets[defaultDailyLimitStrategy]!;
}

class DailyLimitStrategyState {
  final String strategyKey;

  const DailyLimitStrategyState({required this.strategyKey});

  DailyLimitStrategyPreset get preset =>
      resolveDailyLimitStrategyPreset(strategyKey);
  double get factor => preset.factor;
  String get label => preset.label;
  String get riskLabel => preset.riskLabel;
  String get riskDescription => preset.riskDescription;
}

final dailyLimitStrategyProvider =
    StateNotifierProvider<DailyLimitStrategyNotifier, DailyLimitStrategyState>(
      (ref) => DailyLimitStrategyNotifier(),
    );

class DailyLimitStrategyNotifier
    extends StateNotifier<DailyLimitStrategyState> {
  static const String _storageKey = 'daily_limit_strategy';

  DailyLimitStrategyNotifier()
    : super(
        const DailyLimitStrategyState(strategyKey: defaultDailyLimitStrategy),
      ) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_storageKey);
    if (saved == null || !dailyLimitStrategyPresets.containsKey(saved)) return;
    state = DailyLimitStrategyState(strategyKey: saved);
  }

  Future<void> setStrategy(String strategyKey) async {
    final normalized = strategyKey.toLowerCase();
    if (!dailyLimitStrategyPresets.containsKey(normalized)) {
      return;
    }

    state = DailyLimitStrategyState(strategyKey: normalized);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, normalized);
  }

  Future<void> resetToBalanced() async {
    await setStrategy(defaultDailyLimitStrategy);
  }
}
