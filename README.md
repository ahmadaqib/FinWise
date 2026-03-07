# FinWise Personal

Aplikasi Flutter manajemen keuangan pribadi (offline-first) dengan fokus pada satu profil user dan dukungan AI Gemini untuk insight finansial kontekstual.

## Ringkasan

- Platform: Flutter (Android & iOS)
- Arsitektur: local-first (Hive + SharedPreferences)
- State management: Riverpod
- AI: Google Gemini (`google_generative_ai`)
- Tujuan utama: tracking cashflow harian, kontrol budget aman, dan alert dini agar tidak overspending

## Fitur Inti

- Onboarding profil keuangan personal
- Dashboard: Health Score, Budget Meter, Daily Safe Limit
- CRUD transaksi pemasukan/pengeluaran
- Manajemen `Income Sources` (sumber pendapatan tetap/variabel)
- Laporan bulanan dan ringkasan tren
- AI Advisor untuk rekomendasi berbasis data lokal

## Rumus Utama

- `freeBudget = totalFixedIncome - currentCicilan`
- `remainingBudget = freeBudget - totalExpenseThisMonth`
- `dailySafeLimit = remainingBudget / remainingDaysInMonth`

Status cicilan bersifat **LOCKED** dan tidak boleh dipangkas oleh logika rekomendasi.

## Struktur Project (ringkas)

```text
lib/
├── core/           # theme, constants, utils
├── data/           # models + repositories (Hive)
├── providers/      # Riverpod providers
├── features/       # onboarding, dashboard, transaksi, laporan, AI, settings
└── shared/         # reusable widgets/extensions
```

## Menjalankan Project

```bash
flutter pub get
flutter run
```

## Build Runner (Hive/Riverpod codegen)

```bash
dart run build_runner build --delete-conflicting-outputs
```