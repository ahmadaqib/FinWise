# FinWise Personal — Implementation Plan

> **Status:** Draft — Menunggu Approval

## Goal

Membangun aplikasi Flutter manajemen keuangan personal, offline-first, dengan AI Gemini dari template kosong hingga MVP fungsional.

## Strategi: Hybrid (Foundation Sprint + Vertical Slices)

## Tasks

### Sprint 0: Foundation Setup (1-2 hari)
- [x] Task 0.1: Install semua packages (`pubspec.yaml`) → Verify: `flutter pub get` success
- [x] Task 0.2: Design system (AppColors, AppTextStyles, AppTheme) → Verify: theme applied
- [x] Task 0.3: Hive data models (8 models + annotations) → Verify: `build_runner build` success
- [x] Task 0.4: Repositories (3 repos: transaction, income, profile) → Verify: compile clean
- [x] Task 0.5: Core utils (CurrencyFormatter, DateUtils, AppConstants) → Verify: `Rp 4.250.000` format
- [x] Task 0.6: App shell + routing (main.dart, app.dart, bottom nav, 5 empty screens) → Verify: app launches, 5 tabs navigable

### Sprint 1: Onboarding + Income Sources (3-4 hari)
- [x] Task 1.1: Onboarding flow (multi-step form → Hive + SecureStorage) → Verify: data saved, redirect dashboard
- [x] Task 1.2: Income Source CRUD (create/read/update/archive + change log) → Verify: total recalculates

### Sprint 2: Dashboard + Transactions (4-5 hari)
- [x] Task 2.1: Core providers (budget_provider: DSL, health score, free budget) → Verify: reactive updates
- [x] Task 2.2: Dashboard UI (Health Score arc, Budget Meter, DSL, Quick Add) → Verify: real data displayed
- [x] Task 2.3: Transaction CRUD (bottom sheet, list + filter, edit/delete) → Verify: dashboard updates on add

### Sprint 3: Alerts + Reports (3-4 hari)
- [x] Task 3.1: Alert system (7 alert types, push + in-app) → Verify: budget 70% triggers warning
- [x] Task 3.2: Reports (monthly chart, category breakdown, PDF export) → Verify: chart renders, PDF downloads

### Sprint 4: AI Gemini + Polish (4-5 hari)
- [x] Task 4.1: Gemini integration (service, provider, chat UI, system prompt) → Verify: AI uses real data
- [x] Task 4.2: Settings (profile edit, notification toggle, backup JSON) → Verify: changes propagate
- [x] Task 4.3: Micro-interactions (animated arcs, count-up, card press) → Verify: 60fps smooth

## Done When
- [x] App runs on Android emulator/device
- [x] Full flow: Onboarding → Dashboard → Transactions → Reports → AI Chat
- [x] 7 alert types functional
- [x] `flutter analyze` clean
- [ ] `flutter build apk --debug` BUILD SUCCESSFUL
