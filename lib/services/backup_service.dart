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
    final Map<String, dynamic> backupData = {};

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
          },
        )
        .toList();

    final jsonString = jsonEncode(backupData);

    Directory dir;
    if (Platform.isAndroid) {
      dir =
          (await getExternalStorageDirectory()) ??
          await getApplicationSupportDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File(
      '${dir.path}/FinWise_Backup_${DateTime.now().millisecondsSinceEpoch}.json',
    );
    await file.writeAsString(jsonString);
    return file;
  }

  static Future<void> wipeAllData() async {
    await Hive.box<UserProfile>('user_profile').clear();
    await Hive.box<IncomeSource>(AppConstants.boxIncomeSources).clear();
    await Hive.box<Transaction>(AppConstants.boxTransactions).clear();
    // In a real app we'd also wipe secure storage
  }
}
