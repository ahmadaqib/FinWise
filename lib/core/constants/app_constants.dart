class AppConstants {
  static const String appName = 'FinWise Personal';

  static const String boxTransactions = 'transactions';
  static const String boxIncomeSources = 'income_sources';
  static const String boxUserProfile = 'user_profile';
  static const String boxAiCache = 'ai_cache';

  static const int maxRpdPerDay = 20;
  static const int cacheTtlMinutes = 360; // 6 hours
  static const int maxCacheEntries = 50;

  static const List<Map<String, String>> expenseCategories = [
    {'name': 'Makanan', 'icon': 'utensils', 'color': 'warning'},
    {'name': 'Transport', 'icon': 'car', 'color': 'info'},
    {'name': 'Belanja', 'icon': 'shoppingBag', 'color': 'primary'},
    {'name': 'Tagihan', 'icon': 'receipt', 'color': 'danger'},
    {'name': 'Kesehatan', 'icon': 'activity', 'color': 'success'},
    {'name': 'Hiburan', 'icon': 'tv', 'color': 'warning'},
    {'name': 'Pendidikan', 'icon': 'bookOpen', 'color': 'info'},
    {'name': 'Lainnya', 'icon': 'moreHorizontal', 'color': 'textSecondary'},
  ];

  static const List<Map<String, String>> incomeCategories = [
    {'name': 'Gaji', 'icon': 'wallet', 'color': 'success'},
    {'name': 'Bonus', 'icon': 'gift', 'color': 'warning'},
    {'name': 'Investasi', 'icon': 'trendingUp', 'color': 'info'},
    {'name': 'Freelance', 'icon': 'briefcase', 'color': 'primary'},
    {'name': 'Hadiah', 'icon': 'heart', 'color': 'danger'},
    {'name': 'Lainnya', 'icon': 'moreHorizontal', 'color': 'textSecondary'},
  ];
}
