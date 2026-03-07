import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'data/models/alert_config.dart';
import 'data/models/category.dart';
import 'data/models/income_change_log.dart';
import 'data/models/income_source.dart';
import 'data/models/monthly_summary.dart';
import 'data/models/side_project.dart';
import 'data/models/transaction.dart';
import 'data/models/user_profile.dart';

import 'data/repositories/income_source_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/user_profile_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(IncomeSourceAdapter());
  Hive.registerAdapter(IncomeChangeLogAdapter());
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(MonthlySummaryAdapter());
  Hive.registerAdapter(AlertConfigAdapter());
  Hive.registerAdapter(SideProjectAdapter());

  // Initialize Repositories
  await UserProfileRepository().init();
  await IncomeSourceRepository().init();
  await TransactionRepository().init();

  runApp(const ProviderScope(child: FinWiseApp()));
}
