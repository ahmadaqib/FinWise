import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/models/transaction.dart';
import '../data/repositories/transaction_repository.dart';

final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
      return TransactionNotifier();
    });

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final TransactionRepository _repo = TransactionRepository();

  TransactionNotifier() : super([]) {
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
    DateTime date,
  ) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      type: type,
      category: category,
      note: note,
      date: date,
    );
    await _repo.addTransaction(transaction);
    _load();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repo.updateTransaction(transaction);
    _load();
  }

  Future<void> deleteTransaction(String id) async {
    await _repo.deleteTransaction(id);
    _load();
  }
}
