import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/models/alert_config.dart';
import 'data/models/category.dart';
import 'data/models/income_change_log.dart';
import 'data/models/income_source.dart';
import 'data/models/monthly_summary.dart';
import 'data/models/side_project.dart';
import 'data/models/transaction.dart';
import 'data/models/user_profile.dart';
import 'data/models/ai_cache.dart';

import 'data/repositories/income_source_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'data/repositories/user_profile_repository.dart';
import 'data/repositories/alert_repository.dart';
import 'data/repositories/ai_cache_repository.dart';
import 'providers/rpd_counter_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

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
  Hive.registerAdapter(AiCacheAdapter());

  // Initialize Repositories
  await UserProfileRepository().init();
  await IncomeSourceRepository().init();
  await TransactionRepository().init();
  await AlertRepository().init();
  await AiCacheRepository().init();
  await RpdCounter.init();
  await RpdCounter.cleanup();

  runApp(const ProviderScope(child: FinWiseApp()));
}
