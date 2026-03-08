import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/income_source.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../../data/repositories/income_source_repository.dart';
import '../../../shared/widgets/bottom_nav_shell.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
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

  InputDecoration _buildInputDecoration(
    String label,
    BuildContext context, {
    String? prefixText,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      prefixText: prefixText,
      filled: true,
      fillColor: isDark ? AppColors.darkCard : AppColors.surface,
      labelStyle: AppTextStyles.body.copyWith(color: AppColors.textMuted),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDark ? AppColors.primaryLight : AppColors.primary,
          width: 2,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
    );
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
            decoration: _buildInputDecoration('Nama Panggilan', context),
            style: AppTextStyles.body,
            validator: (val) =>
                val == null || val.isEmpty ? 'Wajib diisi' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _gaji1Ctrl,
            decoration: _buildInputDecoration(
              'Gaji Tetap 1 (Rp)',
              context,
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            style: AppTextStyles.mono,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _gaji2Ctrl,
            decoration: _buildInputDecoration(
              'Gaji Tetap 2 (Rp)',
              context,
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            style: AppTextStyles.mono,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _cicilan1Ctrl,
            decoration: _buildInputDecoration(
              'Cicilan Bulan Ini (Rp)',
              context,
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            style: AppTextStyles.mono,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _cicilanNormalCtrl,
            decoration: _buildInputDecoration(
              'Cicilan Normal (Rp)',
              context,
              prefixText: 'Rp ',
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [CurrencyInputFormatter()],
            style: AppTextStyles.mono,
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _geminiKeyCtrl,
            decoration: _buildInputDecoration(
              'Gemini API Key (Opsional)',
              context,
            ),
            style: AppTextStyles.body,
            obscureText: true,
          ),
          const SizedBox(height: AppSpacing.xxl),
          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Simpan & Mulai',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
