import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../shared/widgets/flat_card.dart';
import '../../../core/utils/currency_formatter.dart';
import 'package:flutter/services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _salaryDateCtrl;
  late final TextEditingController _efTargetCtrl;
  late final TextEditingController _passiveTargetCtrl;
  late final TextEditingController _netWorthTargetCtrl;

  @override
  void initState() {
    super.initState();
    final profile = UserProfileRepository().getProfile();
    _nameCtrl = TextEditingController(text: profile?.name ?? '');
    _salaryDateCtrl = TextEditingController(
      text: (profile?.salaryDate ?? 25).toString(),
    );
    _efTargetCtrl = TextEditingController(
      text: _formatInitial(profile?.emergencyFundTarget ?? 15000000),
    );
    _passiveTargetCtrl = TextEditingController(
      text: _formatInitial(profile?.monthlyPassiveTarget ?? 5000000),
    );
    _netWorthTargetCtrl = TextEditingController(
      text: _formatInitial(profile?.netWorthTarget ?? 100000000),
    );
  }

  String _formatInitial(double val) {
    if (val == 0) return '';
    return NumberFormat.decimalPattern('id_ID').format(val);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _salaryDateCtrl.dispose();
    _efTargetCtrl.dispose();
    _passiveTargetCtrl.dispose();
    _netWorthTargetCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfileRepository().getProfile();

    if (profile != null) {
      profile.name = _nameCtrl.text.trim();
      final parsedSalaryDate = int.tryParse(_salaryDateCtrl.text);
      profile.salaryDate = (parsedSalaryDate ?? 25).clamp(1, 31);
      
      profile.emergencyFundTarget = CurrencyFormatter.parse(_efTargetCtrl.text);
      profile.monthlyPassiveTarget = CurrencyFormatter.parse(_passiveTargetCtrl.text);
      profile.netWorthTarget = CurrencyFormatter.parse(_netWorthTargetCtrl.text);

      await ProviderScope.containerOf(
        context,
        listen: false,
      ).read(userProfileProvider.notifier).saveProfile(profile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [TextButton(onPressed: _save, child: const Text('Simpan'))],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FlatCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                backgroundColor: AppColors.surfaceCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Data Diri', style: AppTextStyles.heading2),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(LucideIcons.user),
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _salaryDateCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Gajian (1-31)',
                        prefixIcon: Icon(LucideIcons.calendarDays),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        final day = int.tryParse(v ?? '');
                        if (day == null || day < 1 || day > 31) {
                          return 'Masukkan tanggal 1-31';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              FlatCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                backgroundColor: AppColors.surfaceCard,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Finansial (Anchor)', style: AppTextStyles.heading2),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _efTargetCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Target Dana Darurat',
                        prefixIcon: Icon(LucideIcons.shieldCheck),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                      validator: (v) => v!.isEmpty ? 'Target tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passiveTargetCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Target Passive Income/Bulan',
                        prefixIcon: Icon(LucideIcons.trendingUp),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _netWorthTargetCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Target Kekayaan Bersih (Net Worth)',
                        prefixIcon: Icon(LucideIcons.gem),
                        prefixText: 'Rp ',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [CurrencyInputFormatter()],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
