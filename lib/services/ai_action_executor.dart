import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/income_source.dart';
import '../data/models/cicilan.dart';
import '../data/models/cicilan_payment.dart';
import '../core/utils/date_utils.dart';
import '../providers/transaction_provider.dart';
import '../providers/income_provider.dart';
import '../providers/cicilan_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/daily_limit_strategy_provider.dart';

/// Result of an AI action execution.
class ActionResult {
  final bool success;
  final String summary; // Human-readable summary for Gemini to use in response
  final String? error;

  ActionResult({required this.success, required this.summary, this.error});
}

class PendingActionOption {
  final String value;
  final String label;
  final String description;

  const PendingActionOption({
    required this.value,
    required this.label,
    required this.description,
  });
}

/// Represents a pending action parsed from a Gemini FunctionCall.
class PendingAction {
  final String toolName;
  final Map<String, dynamic> args;
  final String displayTitle;
  final String displayDescription;
  final List<PendingActionOption> options;
  final String? recommendedOption;
  final String? optionArgKey;

  PendingAction({
    required this.toolName,
    required this.args,
    required this.displayTitle,
    required this.displayDescription,
    this.options = const [],
    this.recommendedOption,
    this.optionArgKey,
  });

  PendingAction copyWith({
    Map<String, dynamic>? args,
    String? recommendedOption,
  }) {
    return PendingAction(
      toolName: toolName,
      args: args ?? this.args,
      displayTitle: displayTitle,
      displayDescription: displayDescription,
      options: options,
      recommendedOption: recommendedOption ?? this.recommendedOption,
      optionArgKey: optionArgKey,
    );
  }
}

/// Executes AI-requested actions by mapping FunctionCalls to repository methods.
class AiActionExecutor {
  final Ref _ref;
  const AiActionExecutor(this._ref);

  /// Parse a FunctionCall into a PendingAction for confirmation UI.
  PendingAction parseAction(String functionName, Map<String, dynamic> args) {
    switch (functionName) {
      case 'add_transaction':
        final type = args['type'] == 'income' ? 'Pemasukan' : 'Pengeluaran';
        final amount = _formatCurrency(args['amount']);
        return PendingAction(
          toolName: functionName,
          args: args,
          displayTitle: '📝 Catat $type',
          displayDescription:
              '$type: $amount\nKategori: ${args['category']}'
              '${args['note'] != null ? '\nCatatan: "${args['note']}"' : ''}'
              '\nTanggal: ${args['date'] ?? 'Hari ini'}',
        );

      case 'add_income_source':
        return PendingAction(
          toolName: functionName,
          args: args,
          displayTitle: '💰 Tambah Sumber Pendapatan',
          displayDescription:
              '${args['name']}: ${_formatCurrency(args['amount'])}/bulan'
              '\nTipe: ${_formatIncomeType(args['type'])}'
              '\nTanggal diterima: tgl ${args['received_on_day'] ?? 25}',
        );

      case 'update_income_source':
        final changes = <String>[];
        if (args['new_amount'] != null) {
          changes.add('Nominal → ${_formatCurrency(args['new_amount'])}');
        }
        if (args['new_received_on_day'] != null) {
          changes.add('Tanggal terima → tgl ${args['new_received_on_day']}');
        }
        return PendingAction(
          toolName: functionName,
          args: args,
          displayTitle: '✏️ Update Pendapatan',
          displayDescription:
              '${args['name']}\n${changes.join('\n')}'
              '${args['reason'] != null ? '\nAlasan: ${args['reason']}' : ''}',
        );

      case 'add_cicilan':
        return PendingAction(
          toolName: functionName,
          args: args,
          displayTitle: '🏦 Tambah Cicilan',
          displayDescription:
              '${args['name']}'
              '\nTotal: ${_formatCurrency(args['total_amount'])}'
              '\nPer bulan: ${_formatCurrency(args['monthly_amount'])}'
              '\nTenor: ${args['total_tenor']}x'
              '\nJatuh tempo: tgl ${args['due_day'] ?? 25}',
        );

      case 'update_cicilan':
        final changes = <String>[];
        if (args['new_monthly_amount'] != null) {
          changes.add(
            'Cicilan → ${_formatCurrency(args['new_monthly_amount'])}',
          );
        }
        if (args['new_due_day'] != null) {
          changes.add('Jatuh tempo → tgl ${args['new_due_day']}');
        }
        if (args['new_total_tenor'] != null) {
          changes.add('Tenor → ${args['new_total_tenor']}x');
        }
        return PendingAction(
          toolName: functionName,
          args: args,
          displayTitle: '✏️ Update Cicilan',
          displayDescription: '${args['name']}\n${changes.join('\n')}',
        );

      case 'record_cicilan_payment':
        return PendingAction(
          toolName: functionName,
          args: args,
          displayTitle: '✅ Catat Pembayaran Cicilan',
          displayDescription:
              '${args['cicilan_name']}'
              '${args['amount'] != null ? '\nJumlah: ${_formatCurrency(args['amount'])}' : ''}'
              '${args['note'] != null ? '\nCatatan: "${args['note']}"' : ''}',
        );

      case 'set_daily_limit_strategy':
        final currentStrategy = _ref
            .read(dailyLimitStrategyProvider)
            .strategyKey;
        final currentProjection = _ref.read(
          dailyLimitProjectionProvider(currentStrategy),
        );
        final currentLimit = currentProjection.dailyLimit;
        final requestedStrategy = (args['strategy'] as String?)?.toLowerCase();
        final cycle = _ref.read(currentCycleProvider);
        final cycleEnd = cycle['end']!;
        final nextPayday = DateTime(
          cycleEnd.year,
          cycleEnd.month,
          cycleEnd.day + 1,
        );
        final daysToPayday =
            AppDateUtils.getRemainingDaysInCycle(DateTime.now(), cycleEnd) + 1;

        final optionCards = dailyLimitStrategyPresets.values.map((preset) {
          final projection = _ref.read(
            dailyLimitProjectionProvider(preset.key),
          );
          final projectedLimit = projection.dailyLimit;
          final projectedSaldo = projection.estimatedRemainingAtPayday;
          return PendingActionOption(
            value: preset.key,
            label: '${preset.label} • ${_formatCurrency(projectedLimit)}/hari',
            description:
                '${preset.riskLabel}: ${preset.riskDescription}\n'
                'Estimasi sisa saldo saat gajian: ${_formatCurrency(projectedSaldo)}.',
          );
        }).toList();

        return PendingAction(
          toolName: functionName,
          args: args,
          displayTitle: '🎛️ Atur Adaptive Daily Limit',
          displayDescription:
              'Limit aktif saat ini: ${_formatCurrency(currentLimit)}/hari.\n'
              'Sisa $daysToPayday hari menuju gajian ${nextPayday.day}/${nextPayday.month}.\n'
              'Jika ritme saat ini dipertahankan, estimasi sisa saldo saat gajian: '
              '${_formatCurrency(currentProjection.estimatedRemainingAtPayday)}.\n'
              'Pilih strategi yang ingin dipakai. Setiap opsi punya trade-off risiko berbeda.',
          options: optionCards,
          recommendedOption:
              dailyLimitStrategyPresets.containsKey(requestedStrategy)
              ? requestedStrategy
              : currentStrategy,
          optionArgKey: 'strategy',
        );

      default:
        return PendingAction(
          toolName: functionName,
          args: args,
          displayTitle: '⚙️ Aksi',
          displayDescription: 'Tool: $functionName',
        );
    }
  }

  /// Execute a confirmed action.
  Future<ActionResult> execute(PendingAction action) async {
    try {
      switch (action.toolName) {
        case 'add_transaction':
          return await _addTransaction(action.args);
        case 'add_income_source':
          return await _addIncomeSource(action.args);
        case 'update_income_source':
          return await _updateIncomeSource(action.args);
        case 'add_cicilan':
          return await _addCicilan(action.args);
        case 'update_cicilan':
          return await _updateCicilan(action.args);
        case 'record_cicilan_payment':
          return await _recordCicilanPayment(action.args);
        case 'set_daily_limit_strategy':
          return await _setDailyLimitStrategy(action.args);
        default:
          return ActionResult(
            success: false,
            summary: 'Tool "${action.toolName}" tidak dikenali.',
          );
      }
    } catch (e) {
      return ActionResult(
        success: false,
        summary: 'Gagal mengeksekusi: $e',
        error: e.toString(),
      );
    }
  }

  // ─── Private executors ───

  Future<ActionResult> _addTransaction(Map<String, dynamic> args) async {
    final amount = (args['amount'] as num).toDouble();
    final type = args['type'] as String;
    final category = args['category'] as String;
    final note = args['note'] as String?;
    final dateStr = args['date'] as String?;
    final date = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();

    await _ref
        .read(transactionProvider.notifier)
        .addTransaction(amount, type, category, note, date);

    return ActionResult(
      success: true,
      summary:
          'Berhasil mencatat ${type == 'income' ? 'pemasukan' : 'pengeluaran'} '
          '${_formatCurrency(amount)} kategori $category.',
    );
  }

  Future<ActionResult> _addIncomeSource(Map<String, dynamic> args) async {
    final source = IncomeSource(
      id: const Uuid().v4(),
      name: args['name'] as String,
      amount: (args['amount'] as num).toDouble(),
      type: args['type'] as String,
      receivedOnDay: (args['received_on_day'] as int?) ?? 25,
      createdAt: DateTime.now(),
    );

    await _ref.read(incomeProvider.notifier).addSource(source);

    return ActionResult(
      success: true,
      summary:
          'Berhasil menambah sumber pendapatan "${source.name}" sebesar ${_formatCurrency(source.amount)}/bulan.',
    );
  }

  Future<ActionResult> _updateIncomeSource(Map<String, dynamic> args) async {
    final name = args['name'] as String;
    final sources = _ref.read(incomeProvider);
    final match = sources.where(
      (s) => s.name.toLowerCase().contains(name.toLowerCase()),
    );

    if (match.isEmpty) {
      return ActionResult(
        success: false,
        summary: 'Sumber pendapatan "$name" tidak ditemukan.',
      );
    }

    final source = match.first;
    final newAmount = args['new_amount'] != null
        ? (args['new_amount'] as num).toDouble()
        : null;
    final newDay = args['new_received_on_day'] as int?;
    final reason = args['reason'] as String?;

    if (newAmount != null) {
      await _ref
          .read(incomeProvider.notifier)
          .updateSourceNominal(source.id, newAmount, reason);
    }
    if (newDay != null) {
      source.receivedOnDay = newDay;
      await _ref.read(incomeProvider.notifier).updateSource(source);
    }

    return ActionResult(
      success: true,
      summary:
          'Berhasil mengubah "${source.name}"'
          '${newAmount != null ? ' nominal menjadi ${_formatCurrency(newAmount)}' : ''}'
          '${newDay != null ? ' tanggal terima menjadi tgl $newDay' : ''}.',
    );
  }

  Future<ActionResult> _addCicilan(Map<String, dynamic> args) async {
    final startDateStr = args['start_date'] as String?;
    final cicilan = Cicilan(
      id: const Uuid().v4(),
      name: args['name'] as String,
      totalAmount: (args['total_amount'] as num).toDouble(),
      monthlyAmount: (args['monthly_amount'] as num).toDouble(),
      totalTenor: args['total_tenor'] as int,
      dueDay: (args['due_day'] as int?) ?? 25,
      startDate: startDateStr != null
          ? DateTime.parse(startDateStr)
          : DateTime.now(),
      note: args['note'] as String?,
    );

    await _ref.read(cicilanListProvider.notifier).addCicilan(cicilan);

    return ActionResult(
      success: true,
      summary:
          'Berhasil menambah cicilan "${cicilan.name}" sebesar ${_formatCurrency(cicilan.monthlyAmount)}/bulan selama ${cicilan.totalTenor}x.',
    );
  }

  Future<ActionResult> _updateCicilan(Map<String, dynamic> args) async {
    final name = args['name'] as String;
    final cicilans = _ref.read(cicilanListProvider);
    final match = cicilans.where(
      (c) => c.name.toLowerCase().contains(name.toLowerCase()),
    );

    if (match.isEmpty) {
      return ActionResult(
        success: false,
        summary: 'Cicilan "$name" tidak ditemukan.',
      );
    }

    final cicilan = match.first;
    if (args['new_monthly_amount'] != null) {
      cicilan.monthlyAmount = (args['new_monthly_amount'] as num).toDouble();
    }
    if (args['new_due_day'] != null) {
      cicilan.dueDay = args['new_due_day'] as int;
    }
    if (args['new_total_tenor'] != null) {
      cicilan.totalTenor = args['new_total_tenor'] as int;
    }
    if (args['note'] != null) {
      cicilan.note = args['note'] as String;
    }

    await _ref.read(cicilanListProvider.notifier).updateCicilan(cicilan);

    return ActionResult(
      success: true,
      summary: 'Berhasil mengubah cicilan "${cicilan.name}".',
    );
  }

  Future<ActionResult> _recordCicilanPayment(Map<String, dynamic> args) async {
    final name = args['cicilan_name'] as String;
    final cicilans = _ref.read(cicilanListProvider);
    final match = cicilans.where(
      (c) => c.name.toLowerCase().contains(name.toLowerCase()),
    );

    if (match.isEmpty) {
      return ActionResult(
        success: false,
        summary: 'Cicilan "$name" tidak ditemukan.',
      );
    }

    final cicilan = match.first;
    final paidCount = _ref.read(cicilanPaidCountProvider(cicilan.id));
    final paymentNumber = paidCount + 1;

    if (paymentNumber > cicilan.totalTenor) {
      return ActionResult(
        success: false,
        summary:
            'Cicilan "${cicilan.name}" sudah lunas ($paidCount/${cicilan.totalTenor} pembayaran).',
      );
    }

    final amount = args['amount'] != null
        ? (args['amount'] as num).toDouble()
        : cicilan.monthlyAmount;

    final payment = CicilanPayment(
      id: const Uuid().v4(),
      cicilanId: cicilan.id,
      paymentNumber: paymentNumber,
      amount: amount,
      paidDate: DateTime.now(),
      note: args['note'] as String?,
    );

    await _ref
        .read(cicilanPaymentsProvider(cicilan.id).notifier)
        .addPayment(payment);

    return ActionResult(
      success: true,
      summary:
          'Berhasil mencatat pembayaran ke-$paymentNumber dari ${cicilan.totalTenor} '
          'untuk "${cicilan.name}" sebesar ${_formatCurrency(amount)}.',
    );
  }

  Future<ActionResult> _setDailyLimitStrategy(Map<String, dynamic> args) async {
    final strategy = (args['strategy'] as String?)?.toLowerCase();
    if (strategy == null || !dailyLimitStrategyPresets.containsKey(strategy)) {
      return ActionResult(
        success: false,
        summary:
            'Strategi belum dipilih. Pilih salah satu opsi: Konservatif, Seimbang, atau Fleksibel.',
      );
    }

    final preset = resolveDailyLimitStrategyPreset(strategy);
    final beforeLimit = _ref.read(dailySafeLimitProvider);
    await _ref.read(dailyLimitStrategyProvider.notifier).setStrategy(strategy);

    final projection = _ref.read(dailyLimitProjectionProvider(strategy));
    final adjustedLimit = projection.dailyLimit;
    final reason = (args['reason'] as String?)?.trim();
    final delta = adjustedLimit - beforeLimit;
    final changeText = delta.abs() < 1
        ? 'hampir tidak berubah'
        : delta >= 0
        ? 'naik ${_formatCurrency(delta)}'
        : 'turun ${_formatCurrency(delta.abs())}';

    return ActionResult(
      success: true,
      summary:
          'Strategi Adaptive Daily Limit diubah ke ${preset.label}. '
          'Limit harian aktif sekarang ${_formatCurrency(adjustedLimit)}. '
          'Estimasi sisa saldo saat gajian: ${_formatCurrency(projection.estimatedRemainingAtPayday)}. '
          'Perubahan: $changeText. Profil risiko: ${preset.riskLabel.toLowerCase()}.'
          '${reason != null && reason.isNotEmpty ? ' Catatan: $reason.' : ''}',
    );
  }

  // ─── Helpers ───

  String _formatCurrency(dynamic amount) {
    final value = (amount is num) ? amount.toDouble() : 0.0;
    final formatted = value
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
    return 'Rp $formatted';
  }

  String _formatIncomeType(String? type) {
    switch (type) {
      case 'fixed_monthly':
        return 'Gaji Bulanan Tetap';
      case 'variable_monthly':
        return 'Pendapatan Variabel';
      case 'one_time':
        return 'Satu Kali';
      case 'passive':
        return 'Pendapatan Pasif';
      default:
        return type ?? 'Tidak diketahui';
    }
  }
}
