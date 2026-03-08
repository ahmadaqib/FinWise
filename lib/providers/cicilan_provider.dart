import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/models/cicilan.dart';
import '../data/models/cicilan_payment.dart';
import '../data/repositories/cicilan_repository.dart';

part 'cicilan_provider.g.dart';

@riverpod
class CicilanList extends _$CicilanList {
  final _repository = CicilanRepository();

  @override
  List<Cicilan> build() {
    return _repository.getActiveCicilan();
  }

  Future<void> addCicilan(Cicilan cicilan) async {
    await _repository.addCicilan(cicilan);
    state = _repository.getActiveCicilan();
  }

  Future<void> updateCicilan(Cicilan cicilan) async {
    await _repository.updateCicilan(cicilan);
    state = _repository.getActiveCicilan();
  }

  Future<void> deleteCicilan(String id) async {
    await _repository.deleteCicilan(id);
    state = _repository.getActiveCicilan();
  }
}

@riverpod
class CicilanPayments extends _$CicilanPayments {
  final _repository = CicilanRepository();

  @override
  List<CicilanPayment> build(String cicilanId) {
    return _repository.getPayments(cicilanId);
  }

  Future<void> addPayment(CicilanPayment payment) async {
    await _repository.addPayment(payment);
    state = _repository.getPayments(cicilanId);
  }

  Future<void> deletePayment(String paymentId) async {
    await _repository.deletePayment(paymentId);
    state = _repository.getPayments(cicilanId);
  }
}

@riverpod
int cicilanPaidCount(CicilanPaidCountRef ref, String cicilanId) {
  // This is a computed provider that just reads from the repository.
  // We invalidate it by watching the payments list.
  ref.watch(cicilanPaymentsProvider(cicilanId));
  return CicilanRepository().getPaidCount(cicilanId);
}

@riverpod
double totalCicilanThisMonth(TotalCicilanThisMonthRef ref) {
  final cicilans = ref.watch(cicilanListProvider);
  return cicilans.fold(0.0, (sum, c) => sum + c.monthlyAmount);
}
