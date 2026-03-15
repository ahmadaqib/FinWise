import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../data/models/transaction.dart';
import '../data/repositories/transaction_repository.dart';
import 'alert_provider.dart';

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
      return TransactionNotifier(ref);
    });

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final TransactionRepository _repo = TransactionRepository();
  final Ref? _ref;

  TransactionNotifier([this._ref]) : super([]) {
    _load();
  }

  void _load() {
    state = _repo.getAllTransactions();
  }

  Future<void> addTransaction(
    double amount,
    String type,
    String category,
    String? note,
    DateTime date, {
    String? tempImagePath,
  }) async {
    String? persistentPath;

    if (tempImagePath != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(tempImagePath)}';
      final savedImage = await File(
        tempImagePath,
      ).copy('${appDir.path}/$fileName');
      persistentPath = savedImage.path;
    }

    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      type: type,
      category: category,
      note: note,
      date: date,
      imageRef: persistentPath,
    );
    await _repo.addTransaction(transaction);
    _load();
    _triggerSideEffects();
  }

  Future<void> updateTransaction(
    Transaction transaction, {
    String? tempImagePath,
  }) async {
    String? persistentPath = transaction.imageRef;

    if (tempImagePath != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${p.extension(tempImagePath)}';
      final savedImage = await File(
        tempImagePath,
      ).copy('${appDir.path}/$fileName');
      persistentPath = savedImage.path;
    }

    final updatedTx = transaction.copyWith(imageRef: persistentPath);
    await _repo.updateTransaction(updatedTx);
    _load();
    _triggerSideEffects();
  }

  Future<void> deleteTransaction(String id) async {
    await _repo.deleteTransaction(id);
    _load();
    _triggerSideEffects();
  }

  void _triggerSideEffects() {
    _ref?.read(alertRuleProvider).runChecks();
  }
}
