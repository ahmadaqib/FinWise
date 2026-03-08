import 'package:hive_flutter/hive_flutter.dart';
import '../models/cicilan.dart';
import '../models/cicilan_payment.dart';

class CicilanRepository {
  static const String _cicilanBoxName = 'cicilan';
  static const String _paymentBoxName = 'cicilan_payments';

  Box<Cicilan> get _cBox => Hive.box<Cicilan>(_cicilanBoxName);
  Box<CicilanPayment> get _pBox => Hive.box<CicilanPayment>(_paymentBoxName);

  Future<void> init() async {
    if (!Hive.isBoxOpen(_cicilanBoxName)) {
      await Hive.openBox<Cicilan>(_cicilanBoxName);
    }
    if (!Hive.isBoxOpen(_paymentBoxName)) {
      await Hive.openBox<CicilanPayment>(_paymentBoxName);
    }
  }

  // ==== Cicilan Management ====

  List<Cicilan> getAllCicilan() {
    return _cBox.values.toList()
      ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  List<Cicilan> getActiveCicilan() {
    return _cBox.values.where((c) => c.isActive).toList()
      ..sort((a, b) => a.dueDay.compareTo(b.dueDay));
  }

  Cicilan? getCicilanById(String id) {
    try {
      return _cBox.values.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addCicilan(Cicilan cicilan) async {
    await _cBox.put(cicilan.id, cicilan);
  }

  Future<void> updateCicilan(Cicilan cicilan) async {
    await _cBox.put(cicilan.id, cicilan);
  }

  Future<void> deleteCicilan(String id) async {
    await _cBox.delete(id);

    // Cleanup associated payments
    final targetPayments = _pBox.values
        .where((p) => p.cicilanId == id)
        .toList();
    for (var p in targetPayments) {
      await _pBox.delete(p.id);
    }
  }

  // ==== Payment Management ====

  List<CicilanPayment> getPayments(String cicilanId) {
    return _pBox.values.where((p) => p.cicilanId == cicilanId).toList()
      ..sort((a, b) => b.paidDate.compareTo(a.paidDate)); // Newest first
  }

  Future<void> addPayment(CicilanPayment payment) async {
    await _pBox.put(payment.id, payment);
  }

  Future<void> deletePayment(String paymentId) async {
    await _pBox.delete(paymentId);
  }

  int getPaidCount(String cicilanId) {
    return _pBox.values.where((p) => p.cicilanId == cicilanId).length;
  }
}
