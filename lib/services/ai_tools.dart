import 'package:google_generative_ai/google_generative_ai.dart';

/// All Gemini Function Calling tool declarations for FinWise AI Advisor.
/// These define what actions the AI can request (add/update only, no delete).
class AiTools {
  static List<Tool> get tools => [
    Tool(
      functionDeclarations: [
        addTransaction,
        addIncomeSource,
        updateIncomeSource,
        addCicilan,
        updateCicilan,
        recordCicilanPayment,
      ],
    ),
  ];

  // ─── 1. Add Transaction ───
  static final addTransaction = FunctionDeclaration(
    'add_transaction',
    'Catat transaksi pemasukan atau pengeluaran baru.',
    Schema(
      SchemaType.object,
      properties: {
        'amount': Schema(
          SchemaType.number,
          description: 'Nominal transaksi dalam Rupiah (angka positif)',
        ),
        'type': Schema(
          SchemaType.string,
          description: 'Tipe transaksi',
          enumValues: ['income', 'expense'],
        ),
        'category': Schema(
          SchemaType.string,
          description:
              'Kategori. Expense: Makanan, Transport, Belanja, Tagihan, Kesehatan, Hiburan, Pendidikan, Lainnya. Income: Gaji, Bonus, Investasi, Freelance, Hadiah, Lainnya.',
        ),
        'note': Schema(
          SchemaType.string,
          description: 'Catatan opsional',
          nullable: true,
        ),
        'date': Schema(
          SchemaType.string,
          description:
              'Tanggal transaksi format YYYY-MM-DD. Default hari ini jika tidak disebutkan.',
          nullable: true,
        ),
      },
      requiredProperties: ['amount', 'type', 'category'],
    ),
  );

  // ─── 2. Add Income Source ───
  static final addIncomeSource = FunctionDeclaration(
    'add_income_source',
    'Tambah sumber pendapatan baru (gaji, freelance, investasi, dll).',
    Schema(
      SchemaType.object,
      properties: {
        'name': Schema(
          SchemaType.string,
          description: 'Nama sumber pendapatan (misal: Gaji PT ABC)',
        ),
        'amount': Schema(
          SchemaType.number,
          description: 'Nominal pendapatan per bulan dalam Rupiah',
        ),
        'type': Schema(
          SchemaType.string,
          description: 'Tipe pendapatan',
          enumValues: [
            'fixed_monthly',
            'variable_monthly',
            'one_time',
            'passive',
          ],
        ),
        'received_on_day': Schema(
          SchemaType.integer,
          description: 'Tanggal diterima setiap bulan (1-31). Default 25.',
          nullable: true,
        ),
      },
      requiredProperties: ['name', 'amount', 'type'],
    ),
  );

  // ─── 3. Update Income Source ───
  static final updateIncomeSource = FunctionDeclaration(
    'update_income_source',
    'Ubah detail sumber pendapatan yang sudah ada (nominal, tanggal terima, dll).',
    Schema(
      SchemaType.object,
      properties: {
        'name': Schema(
          SchemaType.string,
          description:
              'Nama sumber pendapatan yang ingin diubah (digunakan untuk mencari)',
        ),
        'new_amount': Schema(
          SchemaType.number,
          description: 'Nominal baru dalam Rupiah',
          nullable: true,
        ),
        'new_received_on_day': Schema(
          SchemaType.integer,
          description: 'Tanggal terima baru (1-31)',
          nullable: true,
        ),
        'reason': Schema(
          SchemaType.string,
          description: 'Alasan perubahan (misal: kenaikan gaji)',
          nullable: true,
        ),
      },
      requiredProperties: ['name'],
    ),
  );

  // ─── 4. Add Cicilan ───
  static final addCicilan = FunctionDeclaration(
    'add_cicilan',
    'Tambah cicilan/installment baru (KPR, kendaraan, elektronik, dll).',
    Schema(
      SchemaType.object,
      properties: {
        'name': Schema(
          SchemaType.string,
          description: 'Nama cicilan (misal: KPR Rumah, Motor Honda)',
        ),
        'total_amount': Schema(
          SchemaType.number,
          description: 'Total harga/nilai kredit dalam Rupiah',
        ),
        'monthly_amount': Schema(
          SchemaType.number,
          description: 'Jumlah cicilan per bulan dalam Rupiah',
        ),
        'total_tenor': Schema(
          SchemaType.integer,
          description: 'Total durasi cicilan dalam bulan (misal: 12, 24, 36)',
        ),
        'due_day': Schema(
          SchemaType.integer,
          description: 'Tanggal jatuh tempo tiap bulan (1-31). Default 25.',
          nullable: true,
        ),
        'start_date': Schema(
          SchemaType.string,
          description:
              'Tanggal mulai cicilan format YYYY-MM-DD. Default hari ini.',
          nullable: true,
        ),
        'note': Schema(
          SchemaType.string,
          description: 'Catatan opsional',
          nullable: true,
        ),
      },
      requiredProperties: [
        'name',
        'total_amount',
        'monthly_amount',
        'total_tenor',
      ],
    ),
  );

  // ─── 5. Update Cicilan ───
  static final updateCicilan = FunctionDeclaration(
    'update_cicilan',
    'Ubah detail cicilan yang sudah ada.',
    Schema(
      SchemaType.object,
      properties: {
        'name': Schema(
          SchemaType.string,
          description:
              'Nama cicilan yang ingin diubah (digunakan untuk mencari)',
        ),
        'new_monthly_amount': Schema(
          SchemaType.number,
          description: 'Nominal cicilan bulanan baru',
          nullable: true,
        ),
        'new_due_day': Schema(
          SchemaType.integer,
          description: 'Tanggal jatuh tempo baru (1-31)',
          nullable: true,
        ),
        'new_total_tenor': Schema(
          SchemaType.integer,
          description: 'Total tenor cicilan baru',
          nullable: true,
        ),
        'note': Schema(
          SchemaType.string,
          description: 'Catatan baru',
          nullable: true,
        ),
      },
      requiredProperties: ['name'],
    ),
  );

  // ─── 6. Record Cicilan Payment ───
  static final recordCicilanPayment = FunctionDeclaration(
    'record_cicilan_payment',
    'Catat pembayaran cicilan bulan ini.',
    Schema(
      SchemaType.object,
      properties: {
        'cicilan_name': Schema(
          SchemaType.string,
          description: 'Nama cicilan yang dibayar (digunakan untuk mencari)',
        ),
        'amount': Schema(
          SchemaType.number,
          description:
              'Jumlah yang dibayar. Jika tidak disebutkan, gunakan monthlyAmount dari cicilan.',
          nullable: true,
        ),
        'note': Schema(
          SchemaType.string,
          description: 'Catatan opsional',
          nullable: true,
        ),
      },
      requiredProperties: ['cicilan_name'],
    ),
  );
}
