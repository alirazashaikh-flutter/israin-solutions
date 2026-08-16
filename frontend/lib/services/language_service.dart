import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _langKey = 'app_language';
  static String _currentLanguage = 'en';

  static String get currentLanguage => _currentLanguage;
  static bool get isUrdu => _currentLanguage == 'ur';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_langKey) ?? 'en';
  }

  static Future<void> setLanguage(String lang) async {
    _currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langKey, lang);
  }

  static const Map<String, String> _strings = {
    // Navigation
    'nav_home_en': 'Home',
    'nav_home_ur': 'ہوم',
    'nav_inquiries_en': 'Inquiries',
    'nav_inquiries_ur': 'انکوائریز',
    'nav_profile_en': 'Profile',
    'nav_profile_ur': 'پروفائل',

    // Headers
    'welcome_back_en': 'Welcome Back',
    'welcome_back_ur': 'خوش آمدید',
    'services_en': 'Services',
    'services_ur': 'سروسز',
    'search_services_en': 'Search services...',
    'search_services_ur': 'سروسز تلاش کریں...',
    'browse_category_en': 'Browse by Category',
    'browse_category_ur': 'زمرے سے دیکھیں',
    'why_choose_us_en': 'Why Choose Us?',
    'why_choose_us_ur': 'ہم کیوں منتخب کریں؟',
    'what_clients_say_en': 'What Our Clients Say',
    'what_clients_say_ur': 'ہمارے گاہک کیا کہتے ہیں',
    'request_service_en': 'Request Service',
    'request_service_ur': 'سروس کی درخواست کریں',

    // Profile
    'account_settings_en': 'ACCOUNT SETTINGS',
    'account_settings_ur': 'اکاؤنٹ ترتیبات',
    'personal_details_en': 'Personal Details',
    'personal_details_ur': 'ذاتی تفصیلات',
    'customer_dashboard_en': 'Customer Dashboard',
    'customer_dashboard_ur': 'گاہک ڈیش بورڈ',
    'company_profile_en': 'Company Profile',
    'company_profile_ur': 'کمپنی پروفائل',
    'faq_en': 'FAQ',
    'faq_ur': 'عمومی سوالات',
    'preferences_en': 'PREFERENCES',
    'preferences_ur': 'ترجیحات',
    'dark_mode_en': 'Dark Mode',
    'dark_mode_ur': 'ڈارک موڈ',
    'dark_active_en': 'Dark theme active',
    'dark_active_ur': 'ڈارک تھیم فعال',
    'light_active_en': 'Light theme active',
    'light_active_ur': 'لائٹ تھیم فعال',
    'language_en': 'Language',
    'language_ur': 'زبان',
    'english_en': 'English',
    'english_ur': 'انگریزی',
    'urdu_en': 'Urdu',
    'urdu_ur': 'اردو',
    'two_factor_en': 'Two-Factor Auth',
    'two_factor_ur': 'دو مرحلہ تصدیق',
    'two_factor_desc_en': 'Extra security for your account',
    'two_factor_desc_ur': 'آپ کے اکاؤنٹ کے لیے اضافی سیکیورٹی',
    'legal_en': 'LEGAL',
    'legal_ur': 'قانونی',
    'privacy_policy_en': 'Privacy Policy',
    'privacy_policy_ur': 'رازداری کی پالیسی',
    'terms_of_service_en': 'Terms of Service',
    'terms_of_service_ur': 'سروس کی شرائط',
    'logout_en': 'Logout',
    'logout_ur': 'لاگ آؤٹ',
    'edit_profile_en': 'Edit Profile',
    'edit_profile_ur': 'پروفائل میں ترمیم',
    'name_en': 'NAME',
    'name_ur': 'نام',
    'phone_en': 'PHONE',
    'phone_ur': 'فون',
    'save_changes_en': 'Save Changes',
    'save_changes_ur': 'تبدیلیاں محفوظ کریں',

    // Other
    'from_en': 'From',
    'from_ur': 'سے',
    'popular_en': 'Popular',
    'popular_ur': 'مقبول',
    'requests_en': 'requests',
    'requests_ur': 'درخواستیں',
    'live_analytics_en': 'Live Analytics',
    'live_analytics_ur': 'لائیو اینالیٹکس',
    'good_morning_en': 'Good morning',
    'good_morning_ur': 'صبح بخیر',
    'good_afternoon_en': 'Good afternoon',
    'good_afternoon_ur': 'دوپہر بخیر',
    'good_evening_en': 'Good evening',
    'good_evening_ur': 'شام بخیر',
    'ready_scale_en': 'Ready to scale your digital operations?',
    'ready_scale_ur': 'اپنے ڈیجیٹل آپریشنز کو بڑھانے کے لیے تیار؟',
    'verified_ethics_en': 'Verified Ethics',
    'verified_ethics_ur': 'تصدیق شدہ اخلاقیات',
    'responsible_ai_en': 'Responsible AI built with integrity.',
    'responsible_ai_ur': 'ذمہ دار AI مع integrity کے ساتھ۔',
    'high_velocity_en': 'High Velocity',
    'high_velocity_ur': 'تیز رفتار',
    'deployment_days_en': 'Deployment in days, not months.',
    'deployment_days_ur': 'دنوں میں تقرری، مہینوں میں نہیں۔',
  };

  static String t(String key) {
    final lookupKey = '${key}_$_currentLanguage';
    return _strings[lookupKey] ?? key;
  }
}
