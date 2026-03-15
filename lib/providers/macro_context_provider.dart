import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/macro_context_service.dart';

final macroContextProvider = FutureProvider<MacroContextSnapshot?>((ref) async {
  final service = ref.watch(macroContextServiceProvider);
  return service.fetchLatest();
});
