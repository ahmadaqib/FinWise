import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../providers/income_provider.dart';
import '../../../../data/models/income_source.dart';
import '../../../../core/theme/app_colors.dart';

class IncomeSourceForm extends ConsumerStatefulWidget {
  final String? incomeId;

  const IncomeSourceForm({super.key, this.incomeId});

  @override
  ConsumerState<IncomeSourceForm> createState() => _IncomeSourceFormState();
}

class _IncomeSourceFormState extends ConsumerState<IncomeSourceForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _dayCtrl;

  String _type = 'fixed_monthly';
  bool _isEditing = false;
  IncomeSource? _existingSource;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.incomeId != null;

    if (_isEditing) {
      final incomes = ref.read(incomeProvider);
      _existingSource = incomes.firstWhere((i) => i.id == widget.incomeId);

      _nameCtrl = TextEditingController(text: _existingSource!.name);
      _amountCtrl = TextEditingController(
        text: _existingSource!.amount.toStringAsFixed(0),
      );
      _dayCtrl = TextEditingController(
        text: _existingSource!.receivedOnDay.toString(),
      );
      _type = _existingSource!.type;
    } else {
      _nameCtrl = TextEditingController();
      _amountCtrl = TextEditingController();
      _dayCtrl = TextEditingController(text: '25');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _dayCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameCtrl.text;
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final day = int.tryParse(_dayCtrl.text) ?? 1;

    if (_isEditing) {
      if (_existingSource!.amount != amount) {
        ref
            .read(incomeProvider.notifier)
            .updateSourceNominal(widget.incomeId!, amount, 'Manual Update');
      }
      _existingSource!.name = name;
      _existingSource!.receivedOnDay = day;
      _existingSource!.type = _type;
      ref.read(incomeProvider.notifier).updateSource(_existingSource!);
    } else {
      final newSource = IncomeSource(
        id: const Uuid().v4(),
        name: name,
        amount: amount,
        type: _type,
        receivedOnDay: day,
        createdAt: DateTime.now(),
      );
      ref.read(incomeProvider.notifier).addSource(newSource);
    }

    Navigator.of(context).pop();
  }

  void _archive() {
    if (_isEditing) {
      ref.read(incomeProvider.notifier).archiveSource(widget.incomeId!);
      Navigator.of(context).pop();
    }
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
            Text(
              _isEditing ? 'Edit Sumber Pemasukan' : 'Tambah Sumber Pemasukan',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Sumber'),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
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
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: const InputDecoration(labelText: 'Tipe'),
                    items: const [
                      DropdownMenuItem(
                        value: 'fixed_monthly',
                        child: Text('Gaji Tetap'),
                      ),
                      DropdownMenuItem(
                        value: 'variable_monthly',
                        child: Text('Gaji Variabel'),
                      ),
                      DropdownMenuItem(
                        value: 'one_time',
                        child: Text('Sekali Terima'),
                      ),
                      DropdownMenuItem(value: 'passive', child: Text('Pasif')),
                    ],
                    onChanged: (v) => setState(() => _type = v!),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextFormField(
                    controller: _dayCtrl,
                    decoration: const InputDecoration(labelText: 'Tgl Terima'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(onPressed: _submit, child: const Text('Simpan')),
            if (_isEditing) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _archive,
                style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                child: const Text('Arsipkan Sumber Ini'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
