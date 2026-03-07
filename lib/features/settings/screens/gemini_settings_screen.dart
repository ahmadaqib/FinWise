import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/user_profile_repository.dart';
import '../../../services/gemini_service.dart';

class GeminiSettingsScreen extends ConsumerStatefulWidget {
  const GeminiSettingsScreen({super.key});

  @override
  ConsumerState<GeminiSettingsScreen> createState() =>
      _GeminiSettingsScreenState();
}

class _GeminiSettingsScreenState extends ConsumerState<GeminiSettingsScreen> {
  final _keyCtrl = TextEditingController();
  final _repo = UserProfileRepository();
  bool _isLoading = false;
  bool _isObscured = true;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final key = await _repo.getGeminiApiKey();
    if (key != null) {
      _keyCtrl.text = key;
    }
  }

  Future<void> _saveKey() async {
    setState(() => _isLoading = true);
    await _repo.saveGeminiApiKey(_keyCtrl.text.trim());
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key berhasil disimpan')),
      );
    }
  }

  Future<void> _testConnection() async {
    if (_keyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan API Key terlebih dahulu')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final service = ref.read(geminiServiceProvider);
    try {
      // Small test request
      final response = await service.askAdvisor('Ping?');
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Koneksi Berhasil'),
            content: Text('AI Berespon: $response'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Koneksi Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini AI Advisor')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primaryMuted,
              child: Icon(LucideIcons.bot, size: 40, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Konfigurasi Kecerdasan Buatan',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Masukkan Google Gemini API Key Anda untuk mengaktifkan fitur Financial Advisor.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _keyCtrl,
            obscureText: _isObscured,
            decoration: InputDecoration(
              labelText: 'Gemini API Key',
              hintText: 'AIza...',
              prefixIcon: const Icon(LucideIcons.key),
              suffixIcon: IconButton(
                icon: Icon(_isObscured ? LucideIcons.eye : LucideIcons.eyeOff),
                onPressed: () => setState(() => _isObscured = !_isObscured),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isLoading ? null : _testConnection,
                  icon: const Icon(LucideIcons.zap, size: 18),
                  label: const Text('Cek Koneksi'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveKey,
                  icon: const Icon(LucideIcons.save, size: 18),
                  label: const Text('Simpan Key'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'Cara Mendapatkan Key:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            '1. Kunjungi Google AI Studio (aistudio.google.com)\n'
            '2. Login dengan akun Google Anda\n'
            '3. Klik "Get API Key" dan buat key baru\n'
            '4. Salin dan tempel di atas gratis.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
