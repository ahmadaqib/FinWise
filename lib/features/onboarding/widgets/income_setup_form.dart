import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/income_source.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../../data/repositories/income_source_repository.dart';
import '../../../shared/widgets/bottom_nav_shell.dart';
import 'package:uuid/uuid.dart';

class IncomeSetupForm extends StatefulWidget {
  const IncomeSetupForm({super.key});

  @override
  State<IncomeSetupForm> createState() => _IncomeSetupFormState();
}

class _IncomeSetupFormState extends State<IncomeSetupForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _gaji1Ctrl = TextEditingController(text: '4.750.000');
  final _gaji2Ctrl = TextEditingController(text: '2.500.000');
  final _cicilan1Ctrl = TextEditingController(text: '3.000.000');
  final _cicilanNormalCtrl = TextEditingController(text: '2.000.000');
  final _geminiKeyCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gaji1Ctrl.dispose();
    _gaji2Ctrl.dispose();
    _cicilan1Ctrl.dispose();
    _cicilanNormalCtrl.dispose();
    _geminiKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final repo = UserProfileRepository();
    final incomeRepo = IncomeSourceRepository();

    final gaji1 = CurrencyFormatter.parse(_gaji1Ctrl.text);
    final gaji2 = CurrencyFormatter.parse(_gaji2Ctrl.text);

    // Save Profile
    final profile = UserProfile(
      name: _nameCtrl.text,
      fixedIncome1: gaji1,
      fixedIncome2: gaji2,
      cicilanMonth1: CurrencyFormatter.parse(_cicilan1Ctrl.text),
      cicilanNormal: CurrencyFormatter.parse(_cicilanNormalCtrl.text),
      isMonth1: true,
    );
    await repo.saveProfile(profile);

    // Bootstrap initial income sources
    if (gaji1 > 0) {
      await incomeRepo.addIncomeSource(
        IncomeSource(
          id: const Uuid().v4(),
          name: 'Gaji Tetap 1',
          amount: gaji1,
          type: 'fixed_monthly',
          receivedOnDay: 25,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
    }

    if (gaji2 > 0) {
      await incomeRepo.addIncomeSource(
        IncomeSource(
          id: const Uuid().v4(),
          name: 'Gaji Tetap 2',
          amount: gaji2,
          type: 'fixed_monthly',
          receivedOnDay: 28,
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
    }

    // Save Gemini Key
    if (_geminiKeyCtrl.text.isNotEmpty) {
      await repo.saveGeminiApiKey(_geminiKeyCtrl.text);
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const BottomNavShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Nama Panggilan'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _gaji1Ctrl,
            decoration: const InputDecoration(
              labelText: 'Gaji Tetap 1 (Rp)',
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            style: const TextStyle(fontFamily: 'JetBrainsMono'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _gaji2Ctrl,
            decoration: const InputDecoration(
              labelText: 'Gaji Tetap 2 (Rp)',
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            style: const TextStyle(fontFamily: 'JetBrainsMono'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cicilan1Ctrl,
            decoration: const InputDecoration(
              labelText: 'Cicilan Bulan Ini (Rp)',
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            style: const TextStyle(fontFamily: 'JetBrainsMono'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _cicilanNormalCtrl,
            decoration: const InputDecoration(
              labelText: 'Cicilan Normal (Rp)',
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            style: const TextStyle(fontFamily: 'JetBrainsMono'),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _geminiKeyCtrl,
            decoration: const InputDecoration(
              labelText: 'Gemini API Key (Opsional)',
            ),
            obscureText: true,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Simpan & Masuk'),
          ),
        ],
      ),
    );
  }
}
