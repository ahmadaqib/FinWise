import '../data/models/ai_context_package.dart';
import '../data/models/transaction.dart';
import '../core/utils/currency_formatter.dart';

class LocalPredictionEngine {
  final AIContextPackage context;
  final List<Transaction> transactions;

  LocalPredictionEngine({
    required this.context,
    required this.transactions,
  });

  String? getPrediction(String query) {
    final lowerQuery = query.toLowerCase();

    // 1. Reset / Limit
    if (lowerQuery.contains('reset') || lowerQuery.contains('batas harian') || lowerQuery.contains('limit')) {
      return _handleLimit();
    }

    // 2. Budget / Sisa
    if (lowerQuery.contains('budget') || lowerQuery.contains('sisa') || lowerQuery.contains('uang')) {
      return _handleBudget();
    }

    // 3. Top Category / Boros
    if (lowerQuery.contains('kategori') || lowerQuery.contains('boros') || lowerQuery.contains('paling banyak')) {
      return _handleTopCategory();
    }

    // 4. Payday / Gajian
    if (lowerQuery.contains('gajian') || lowerQuery.contains('kapan')) {
      return _handlePayday();
    }

    // 5. FWS / Score / Kesehatan
    if (lowerQuery.contains('fws') || lowerQuery.contains('score') || lowerQuery.contains('skor') || lowerQuery.contains('sehat')) {
      return _handleFws();
    }

    // 6. Emergency Fund / Dana Darurat
    if (lowerQuery.contains('darurat') || lowerQuery.contains('emergency')) {
      return _handleEmergencyFund();
    }

    // 7. Velocity / Ritme
    if (lowerQuery.contains('ritme') || lowerQuery.contains('cepat') || lowerQuery.contains('laju')) {
      return _handleVelocity();
    }

    return null;
  }

  String _handleLimit() {
    final limit = CurrencyFormatter.format(context.adaptiveDailySafeLimit);
    return 'Batas aman belanja kamu hari ini adalah **$limit**. \n\nAngka ini dihitung secara adaptif berdasarkan sisa budget dan ritme belanja kamu. Jika kamu ingin mereset progress hari ini, kamu bisa menggunakan tombol "Reset Progress" di dashboard.';
  }

  String _handleBudget() {
    final remaining = CurrencyFormatter.format(context.remainingBudget);
    final total = CurrencyFormatter.format(context.totalFixedIncome);
    return 'Sisa budget bebas kamu bulan ini adalah **$remaining** dari total income **$total**. \n\nDengan sisa hari yang ada, usahakan tetap berada di bawah daily limit agar tidak defisit di akhir siklus.';
  }

  String _handleTopCategory() {
    if (transactions.isEmpty) return 'Belum ada transaksi pengeluaran tercatat bulan ini.';

    final categories = <String, double>{};
    for (final tx in transactions) {
      if (tx.type == 'expense') {
        categories[tx.category] = (categories[tx.category] ?? 0) + tx.amount;
      }
    }

    if (categories.isEmpty) return 'Belum ada pengeluaran yang tercatat.';

    final sorted = categories.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.first;
    final topAmount = CurrencyFormatter.format(top.value);

    return 'Pengeluaran terbesar kamu bulan ini ada di kategori **${top.key}** sebesar **$topAmount**. \n\nKategori ini menyumbang ${((top.value / context.totalFixedIncome) * 100).toStringAsFixed(1)}% dari total income kamu.';
  }

  String _handlePayday() {
    // Assuming cycle end is the day before next payday
    // We can't easily get the exact date here without looking at currentCycleProvider logic,
    // but we have remainingBudget and context info.
    // For now, let's use a generic but helpful response.
    return 'Siklus keuangan kamu akan berakhir dalam beberapa hari lagi. Pastikan sisa budget **${CurrencyFormatter.format(context.remainingBudget)}** cukup untuk memenuhi kebutuhan sampai tanggal gajian tiba.';
  }

  String _handleFws() {
    return 'Skor FinWise (FWS) kamu saat ini adalah **${context.currentFWS.toInt()}** yang masuk dalam kategori **${context.fwsBand}**. \n\n${_getFwsAdvice(context.currentFWS)}';
  }

  String _getFwsAdvice(double score) {
    if (score < 200) return 'Kondisi keuanganmu sedang rapuh. Prioritaskan membangun dana darurat dan kurangi liabilitas.';
    if (score < 400) return 'Kamu sedang bertahan (surviving). Fokus pada stabilitas cashflow dan mulai isi ZONE GROW.';
    if (score < 600) return 'Keuanganmu stabil. Pertahankan konsistensi di ZONE GROW untuk masa depan.';
    return 'Luar biasa! Keuanganmu sangat sehat. Fokus pada pengembangan aset dan kebebasan finansial.';
  }

  String _handleEmergencyFund() {
    final progress = context.emergencyFundProgress.toStringAsFixed(1);
    return 'Progress Dana Darurat kamu saat ini adalah **$progress%**. \n\nDana darurat diakumulasikan secara otomatis dari sisa budget bulanan kamu di ZONE SHIELD. Tetap konsisten mengisi zona ini ya!';
  }

  String _handleVelocity() {
    final velocity = context.spendingVelocity.toStringAsFixed(2);
    final status = context.spendingVelocity > 1.0 ? 'lebih cepat' : 'lebih lambat';
    return 'Laju belanja kamu saat ini adalah **${velocity}x**, yang artinya kamu belanja **$status** dari idealnya (1.00x). \n\n${context.spendingVelocity > 1.1 ? 'Hati-hati, sebaiknya rem sedikit pengeluaran di ZONE FREE.' : 'Bagus! Ritme belanjamu masih sangat terkontrol.'}';
  }
}
