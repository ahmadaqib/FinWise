import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../data/models/user_profile.dart';
import '../data/models/income_source.dart';
import '../data/models/transaction.dart';
import '../core/constants/app_constants.dart';

class BackupService {
  static Future<File> exportDataToJson() async {
    final Map<String, dynamic> backupData = {
      'version': '1.0.0',
      'exportedAt': DateTime.now().toIso8601String(),
    };

    // 1. Profile
    final profileBox = Hive.box<UserProfile>('user_profile');
    final profile = profileBox.get('main_profile');
    if (profile != null) {
      backupData['profile'] = {
        'name': profile.name,
        'fixedIncome1': profile.fixedIncome1,
        'fixedIncome2': profile.fixedIncome2,
        'cicilanMonth1': profile.cicilanMonth1,
        'cicilanNormal': profile.cicilanNormal,
        'isMonth1': profile.isMonth1,
      };
    }

    // 2. Incomes
    final incomeBox = Hive.box<IncomeSource>(AppConstants.boxIncomeSources);
    backupData['incomes'] = incomeBox.values
        .map(
          (i) => {
            'id': i.id,
            'name': i.name,
            'amount': i.amount,
            'type': i.type,
            'receivedOnDay': i.receivedOnDay,
            'isActive': i.isActive,
            'createdAt': i.createdAt.toIso8601String(),
            'deactivatedAt': i.deactivatedAt?.toIso8601String(),
            'quadrant': i.quadrant,
          },
        )
        .toList();

    // 3. Transactions
    final transactionBox = Hive.box<Transaction>(AppConstants.boxTransactions);
    backupData['transactions'] = transactionBox.values
        .map(
          (t) => {
            'id': t.id,
            'amount': t.amount,
            'type': t.type,
            'category': t.category,
            'note': t.note,
            'date': t.date.toIso8601String(),
            'isRecurring': t.isRecurring,
            'imageRef': t.imageRef,
            'spendingMood': t.spendingMood,
            'transactionNature': t.transactionNature,
          },
        )
        .toList();

    final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

    // Use temporary directory for sharing
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${tempDir.path}/FinWise_Backup_$timestamp.json');

    await file.writeAsString(jsonString);
    return file;
  }

  static Future<void> importDataFromJson(String jsonString) async {
    final Map<String, dynamic> backupData = jsonDecode(jsonString);

    // Simple validation
    if (!backupData.containsKey('profile') ||
        !backupData.containsKey('incomes') ||
        !backupData.containsKey('transactions')) {
      throw Exception('Format file backup tidak valid');
    }

    // 1. Clear existing data
    await wipeAllData();

    // 2. Restore Profile
    final profileBox = Hive.box<UserProfile>('user_profile');
    final pMap = backupData['profile'];
    await profileBox.put(
      'main_profile',
      UserProfile(
        name: pMap['name'] ?? '',
        fixedIncome1: (pMap['fixedIncome1'] ?? 0).toDouble(),
        fixedIncome2: (pMap['fixedIncome2'] ?? 0).toDouble(),
        cicilanMonth1: (pMap['cicilanMonth1'] ?? 0).toDouble(),
        cicilanNormal: (pMap['cicilanNormal'] ?? 0).toDouble(),
        isMonth1: pMap['isMonth1'] ?? true,
      ),
    );

    // 3. Restore Incomes
    final incomeBox = Hive.box<IncomeSource>(AppConstants.boxIncomeSources);
    final List incomes = backupData['incomes'];
    for (var i in incomes) {
      await incomeBox.add(
        IncomeSource(
          id: i['id'] ?? '',
          name: i['name'] ?? '',
          amount: (i['amount'] ?? 0).toDouble(),
          type: i['type'] ?? 'Active',
          receivedOnDay: i['receivedOnDay'] ?? 1,
          isActive: i['isActive'] ?? true,
          createdAt: DateTime.parse(
            i['createdAt'] ?? DateTime.now().toIso8601String(),
          ),
          deactivatedAt: i['deactivatedAt'] != null
              ? DateTime.parse(i['deactivatedAt'])
              : null,
          quadrant: i['quadrant'] ?? 'E',
          changeLog: const [],
        ),
      );
    }

    // 4. Restore Transactions
    final transactionBox = Hive.box<Transaction>(AppConstants.boxTransactions);
    final List transactions = backupData['transactions'];
    for (var t in transactions) {
      await transactionBox.add(
        Transaction(
          id: t['id'] ?? '',
          amount: (t['amount'] ?? 0).toDouble(),
          type: t['type'] ?? 'Outcome',
          category: t['category'] ?? '',
          note: t['note'] ?? '',
          date: DateTime.parse(t['date']),
          isRecurring: t['isRecurring'] ?? false,
          imageRef: t['imageRef'],
          spendingMood: t['spendingMood'],
          transactionNature: t['transactionNature'],
        ),
      );
    }
  }

  static Future<void> wipeAllData() async {
    await Hive.box<UserProfile>('user_profile').clear();
    await Hive.box<IncomeSource>(AppConstants.boxIncomeSources).clear();
    await Hive.box<Transaction>(AppConstants.boxTransactions).clear();
  }
}
