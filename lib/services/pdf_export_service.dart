import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../core/utils/currency_formatter.dart';
import '../data/models/transaction.dart';

class PdfExportService {
  static Future<File> generateMonthlyReport(
    int month,
    int year,
    List<Transaction> transactions,
  ) async {
    final pdf = pw.Document();

    final expenses = transactions.where((t) => t.type == 'expense').toList();
    final incomes = transactions.where((t) => t.type == 'income').toList();

    final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);
    final totalIncome = incomes.fold(0.0, (sum, t) => sum + t.amount);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text(
                  'Laporan Keuangan FinWise - $month/$year',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Summary Table
              pw.TableHelper.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['Keterangan', 'Total'],
                  <String>[
                    'Total Pemasukan',
                    CurrencyFormatter.format(totalIncome),
                  ],
                  <String>[
                    'Total Pengeluaran',
                    CurrencyFormatter.format(totalExpense),
                  ],
                  <String>[
                    'Sisa',
                    CurrencyFormatter.format(totalIncome - totalExpense),
                  ],
                ],
              ),
              pw.SizedBox(height: 30),

              // Detail Pengeluaran
              pw.Text(
                'Rincian Pengeluaran',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              if (expenses.isEmpty)
                pw.Text('Tidak ada pengeluaran bulan ini.')
              else
                pw.TableHelper.fromTextArray(
                  context: context,
                  headers: ['Tanggal', 'Kategori', 'Catatan', 'Nominal'],
                  data: expenses
                      .map(
                        (t) => [
                          '\${t.date.day}/\${t.date.month}',
                          t.category,
                          t.note ?? '-',
                          CurrencyFormatter.format(t.amount),
                        ],
                      )
                      .toList(),
                ),
            ],
          );
        },
      ),
    );

    Directory dir;
    if (Platform.isAndroid) {
      dir =
          (await getExternalStorageDirectory()) ??
          await getApplicationSupportDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final file = File('${dir.path}/FinWise_Laporan_${month}_$year.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}
