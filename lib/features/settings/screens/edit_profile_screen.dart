import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../shared/widgets/flat_card.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _salaryDateCtrl;

  @override
  void initState() {
    super.initState();
    final profile = UserProfileRepository().getProfile();
    _nameCtrl = TextEditingController(text: profile?.name ?? '');
    _salaryDateCtrl = TextEditingController(
      text: (profile?.salaryDate ?? 25).toString(),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _salaryDateCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfileRepository().getProfile();

    if (profile != null) {
      profile.name = _nameCtrl.text.trim();
      final parsedSalaryDate = int.tryParse(_salaryDateCtrl.text);
      profile.salaryDate = (parsedSalaryDate ?? 25).clamp(1, 31);

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
