import 'package:flutter_test/flutter_test.dart';
import 'package:FinWise/algorithms/local_prediction_engine.dart';
import '../helpers/test_fixtures.dart';

void main() {
  group('LocalPredictionEngine Tests', () {
    test('Returns budget prediction when query contains "budget"', () {
      final context = TestFixtures.mockAIContext(freeBudget: 500000);
      final engine = LocalPredictionEngine(context: context, transactions: []);
      
      final result = engine.getPrediction('berapa sisa budget saya?');
      
      expect(result, contains('500.000'));
      expect(result, contains('Sisa budget bebas'));
    });

    test('Returns limit prediction when query contains "limit"', () {
      final context = TestFixtures.mockAIContext();
      final engine = LocalPredictionEngine(context: context, transactions: []);
      
      final result = engine.getPrediction('apa limit harian saya?');
      
      expect(result, contains('Batas aman belanja'));
      expect(result, contains('100.000'));
    });

    test('Returns top category correctly', () {
      final context = TestFixtures.mockAIContext();
      final transactions = [
        TestFixtures.mockExpense(amount: 100000, category: 'Food'),
        TestFixtures.mockExpense(amount: 200000, category: 'Bills'),
        TestFixtures.mockExpense(amount: 50000, category: 'Food'),
      ];
      final engine = LocalPredictionEngine(context: context, transactions: transactions);
      
      final result = engine.getPrediction('saya paling boros di mana?');
      
      expect(result, contains('Bills'));
      expect(result, contains('200.000'));
    });

    test('Returns FWS info correctly', () {
      final context = TestFixtures.mockAIContext(currentFWS: 750.0);
      final engine = LocalPredictionEngine(context: context, transactions: []);
      
      final result = engine.getPrediction('cek skor fws');
      
      expect(result, contains('750'));
      expect(result, contains('Luar biasa!'));
    });

    test('Returns null for unknown query', () {
      final context = TestFixtures.mockAIContext();
      final engine = LocalPredictionEngine(context: context, transactions: []);
      
      final result = engine.getPrediction('siapa presiden pertama indonesia?');
      
      expect(result, isNull);
    });
  });
}
