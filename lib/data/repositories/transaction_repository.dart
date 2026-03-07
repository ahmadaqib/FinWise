import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class TransactionRepository {
  static const String boxName = 'transactions';

  Box<Transaction> get _box => Hive.box<Transaction>(boxName);

  Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<Transaction>(boxName);
    }
  }

  List<Transaction> getAllTransactions() {
    return _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await transaction.save();
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
  }
}
