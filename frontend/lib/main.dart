import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'config/colors.dart';
import 'providers/auth_provider.dart';
import 'providers/inquiry_provider.dart';
import 'providers/message_provider.dart';
import 'providers/service_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/services/service_detail_screen.dart';
import 'screens/services/compare_screen.dart';
import 'screens/services/inquiry_form_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'screens/chat/chat_with_ai_screen.dart';
import 'screens/inquiries/my_inquiries_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/admin/admin_inquiries_screen.dart';
import 'screens/admin/admin_services_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/verify_otp_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/privacy_policy_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/contact/contact_us_screen.dart';
import 'screens/profile/company_profile_screen.dart';
import 'screens/profile/faq_screen.dart';
import 'screens/home/customer_dashboard_screen.dart';
import 'screens/services/service_categories_screen.dart';
import 'screens/shop/shop_screen.dart';
import 'screens/shop/product_detail_screen.dart';
import 'screens/shop/my_orders_screen.dart';
import 'screens/admin/admin_orders_screen.dart';
import 'services/language_service.dart';
import 'widgets/responsive_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageService.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InquiryProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => ServiceProvider()),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, auth, _) {
          AppColors.setDarkMode(themeProvider.isDark);
          final isRtl = LanguageService.isUrdu;

          return MaterialApp(
            title: 'Israin Solutions',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            locale: isRtl ? const Locale('ur', 'PK') : const Locale('en', 'US'),
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ur', 'PK'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.surface,
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.onPrimary,
                secondary: AppColors.secondary,
                onSecondary: AppColors.onSecondary,
                surface: AppColors.surface,
                onSurface: AppColors.onSurface,
                error: AppColors.error,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              textTheme: GoogleFonts.interTextTheme(),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.surface,
              colorScheme: ColorScheme.dark(
                primary: AppColors.primary,
                onPrimary: AppColors.onPrimary,
                secondary: AppColors.secondary,
                onSecondary: AppColors.onSecondary,
                surface: AppColors.surface,
                onSurface: AppColors.onSurface,
                error: AppColors.error,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
            ),
            builder: (context, child) {
              return Directionality(
                textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
                child: ResponsiveLayout(child: child!),
              );
            },
            home: const SplashScreen(),
            routes: {
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/verify-otp': (context) {
                final email = (ModalRoute.of(context)?.settings.arguments ?? '') as String;
                return VerifyOtpScreen(email: email);
              },
              '/reset-password': (context) {
                final args = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map;
                return ResetPasswordScreen(
                  email: (args['email'] ?? '') as String,
                  resetToken: (args['resetToken'] ?? '') as String,
                );
              },
              '/home': (context) => const HomeScreen(),
              '/service-detail': (context) => const ServiceDetailScreen(),
              '/compare': (context) => const CompareScreen(),
              '/inquiry-form': (context) => const InquiryFormScreen(),
              '/chat': (context) => const ChatScreen(),
              '/chat-ai': (context) => const ChatWithAIScreen(),
              '/my-inquiries': (context) => const MyInquiriesScreen(),
              '/admin': (context) => const AdminDashboardScreen(),
              '/admin-inquiries': (context) => const AdminInquiriesScreen(),
              '/admin-services': (context) => const AdminServicesScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/privacy-policy': (context) => const PrivacyPolicyScreen(title: 'Privacy Policy'),
              '/terms-of-service': (context) => const PrivacyPolicyScreen(title: 'Terms of Service'),
              '/notifications': (context) => const NotificationsScreen(),
              '/contact-us': (context) => const ContactUsScreen(),
              '/company-profile': (context) => const CompanyProfileScreen(),
              '/faq': (context) => const FaqScreen(),
              '/customer-dashboard': (context) => const CustomerDashboardScreen(),
              '/service-categories': (context) => const ServiceCategoriesScreen(),
              '/shop': (context) => const ShopScreen(),
              '/product-detail': (context) => const ProductDetailScreen(),
              '/my-orders': (context) => const MyOrdersScreen(),
              '/admin-orders': (context) => const AdminOrdersScreen(),
            },
          );
        },
      ),
    );
  }
}
