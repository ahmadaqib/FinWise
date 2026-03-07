import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers/transaction_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';

class TransactionForm extends ConsumerStatefulWidget {
  const TransactionForm({super.key});

  @override
  ConsumerState<TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends ConsumerState<TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  String _type = 'expense';
  String _category = AppConstants.defaultCategories.first['name']!;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    ref
        .read(transactionProvider.notifier)
        .addTransaction(
          amount,
          _type,
          _category,
          _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
          _date,
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tambah Transaksi Baru',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Type toggle (Income / Expense)
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                ButtonSegment(value: 'income', label: Text('Pemasukan')),
              ],
              selected: {_type},
              onSelectionChanged: (set) => setState(() => _type = set.first),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp)',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              style: const TextStyle(fontFamily: 'JetBrainsMono'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            if (_type == 'expense')
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: AppConstants.defaultCategories
                    .map(
                      (c) => DropdownMenuItem(
                        value: c['name']!,
                        child: Text(c['name']!),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              )
            else
              const SizedBox.shrink(), // Or we could allow income categories

            if (_type == 'expense') const SizedBox(height: 16),

            TextFormField(
              controller: _noteCtrl,
              decoration: const InputDecoration(
                labelText: 'Catatan (Opsional)',
              ),
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (date != null) setState(() => _date = date);
              },
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Tanggal'),
                child: Text('${_date.day}/${_date.month}/${_date.year}'),
              ),
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Catat Transaksi'),
            ),
          ],
        ),
      ),
    );
  }
}
