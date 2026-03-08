import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../providers/cicilan_provider.dart';
import '../../../data/models/cicilan.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class CicilanForm extends ConsumerStatefulWidget {
  final Cicilan? existingCicilan;

  const CicilanForm({super.key, this.existingCicilan});

  @override
  ConsumerState<CicilanForm> createState() => _CicilanFormState();
}

class _CicilanFormState extends ConsumerState<CicilanForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _totalAmountCtrl;
  late final TextEditingController _monthlyAmountCtrl;
  late final TextEditingController _tenorCtrl;
  late final TextEditingController _dueDayCtrl;
  late final TextEditingController _noteCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCicilan;

    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _totalAmountCtrl = TextEditingController(
      text: c != null ? c.totalAmount.toStringAsFixed(0) : '',
    );
    _monthlyAmountCtrl = TextEditingController(
      text: c != null ? c.monthlyAmount.toStringAsFixed(0) : '',
    );
    _tenorCtrl = TextEditingController(
      text: c != null ? c.totalTenor.toString() : '',
    );
    _dueDayCtrl = TextEditingController(
      text: c != null ? c.dueDay.toString() : '25',
    );
    _noteCtrl = TextEditingController(text: c?.note ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _totalAmountCtrl.dispose();
    _monthlyAmountCtrl.dispose();
    _tenorCtrl.dispose();
    _dueDayCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final id = widget.existingCicilan?.id ?? const Uuid().v4();

    // In a real app we'd parse with formatting, handling raw strings for simplicity:
    // But since we use CurrencyInputFormatter, let's parse via CurrencyFormatter
    final total = CurrencyFormatter.parse(_totalAmountCtrl.text);
    final monthly = CurrencyFormatter.parse(_monthlyAmountCtrl.text);
    final tenor = int.tryParse(_tenorCtrl.text) ?? 12;
    final dueDay = int.tryParse(_dueDayCtrl.text) ?? 1;

    final cicilan = Cicilan(
      id: id,
      name: _nameCtrl.text.trim(),
      totalAmount: total,
      monthlyAmount: monthly,
      totalTenor: tenor,
      startDate: widget.existingCicilan?.startDate ?? DateTime.now(),
      dueDay: dueDay.clamp(1, 31),
      isActive: widget.existingCicilan?.isActive ?? true,
      note: _noteCtrl.text.isEmpty ? null : _noteCtrl.text.trim(),
    );

    if (widget.existingCicilan != null) {
      ref.read(cicilanListProvider.notifier).updateCicilan(cicilan);
    } else {
      ref.read(cicilanListProvider.notifier).addCicilan(cicilan);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingCicilan != null;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? 'Edit Cicilan' : 'Tambah Cicilan Baru',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Cicilan (e.g. KPR, Motor)',
                ),
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _monthlyAmountCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Cicilan per Bulan',
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      style: const TextStyle(fontFamily: 'JetBrainsMono'),
                      validator: (v) => v!.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _tenorCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tenor (Bulan)',
                        suffixText: ' x',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _totalAmountCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Total Pokok Hutang',
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      style: const TextStyle(fontFamily: 'JetBrainsMono'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _dueDayCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tgl Jatuh Tempo',
                        hintText: '1-31',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Wajib';
                        final val = int.tryParse(v);
                        if (val == null || val < 1 || val > 31) return '1-31';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Catatan (Opsional)',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEdit ? 'Simpan Perubahan' : 'Buat Cicilan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
