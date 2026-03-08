import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../../providers/transaction_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';

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
  late String _category;
  DateTime _date = DateTime.now();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    _category = AppConstants.expenseCategories.first['name']!;
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _imageFile = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = CurrencyFormatter.parse(_amountCtrl.text);

    ref
        .read(transactionProvider.notifier)
        .addTransaction(
          amount,
          _type,
          _category,
          _noteCtrl.text.isEmpty ? null : _noteCtrl.text,
          _date,
          tempImagePath: _imageFile?.path,
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == 'expense'
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;

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
              onSelectionChanged: (set) {
                setState(() {
                  _type = set.first;
                  _category =
                      (_type == 'expense'
                              ? AppConstants.expenseCategories
                              : AppConstants.incomeCategories)
                          .first['name']!;
                });
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _amountCtrl,
              decoration: const InputDecoration(
                labelText: 'Nominal (Rp)',
                prefixText: 'Rp ',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [CurrencyInputFormatter()],
              style: const TextStyle(fontFamily: 'JetBrainsMono'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              key: ValueKey(_type), // Force rebuild when type changes
              value: _category,
              decoration: const InputDecoration(labelText: 'Kategori'),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c['name']!,
                      child: Text(c['name']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),

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
            const SizedBox(height: 24),

            // Receipt Photo Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Foto Struk (Opsional)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      icon: const Icon(LucideIcons.image, size: 20),
                      color: AppColors.primary,
                    ),
                    IconButton(
                      onPressed: () => _pickImage(ImageSource.camera),
                      icon: const Icon(LucideIcons.camera, size: 20),
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),

            if (_imageFile != null) ...[
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(File(_imageFile!.path)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _imageFile = null),
                    icon: const CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 12,
                      child: Icon(LucideIcons.x, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],

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
