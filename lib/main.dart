import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'database/product_data_source.dart';
import 'database/category_data_source.dart';
import 'database/exchange_rate_data_source.dart';
import 'database/price_history_data_source.dart';
import 'repositories/product_repository.dart';
import 'repositories/category_repository.dart';
import 'repositories/exchange_rate_repository.dart';
import 'repositories/price_history_repository.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/exchange_rate_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/locale_provider.dart';
import 'core/app_localizations.dart';
import 'services/notification_service.dart';
import 'core/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initNotifications();

  final productDataSource = ProductDataSource();
  final categoryDataSource = CategoryDataSource();
  final exchangeRateDataSource = ExchangeRateDataSource();
  final priceHistoryDataSource = PriceHistoryDataSource();

  final productRepository = ProductRepository(productDataSource);
  final categoryRepository = CategoryRepository(categoryDataSource);
  final exchangeRateRepository = ExchangeRateRepository(exchangeRateDataSource);
  final priceHistoryRepository = PriceHistoryRepository(priceHistoryDataSource);

  runApp(
    MyApp(
      productRepository: productRepository,
      categoryRepository: categoryRepository,
      exchangeRateRepository: exchangeRateRepository,
      priceHistoryRepository: priceHistoryRepository,
    ),
  );
}

class MyApp extends StatelessWidget {
  final ProductRepository productRepository;
  final CategoryRepository categoryRepository;
  final ExchangeRateRepository exchangeRateRepository;
  final PriceHistoryRepository priceHistoryRepository;

  const MyApp({
    Key? key,
    required this.productRepository,
    required this.categoryRepository,
    required this.exchangeRateRepository,
    required this.priceHistoryRepository,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(productRepository, priceHistoryRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(categoryRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ExchangeRateProvider(exchangeRateRepository),
        ),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Shop Prices',
            locale: localeProvider.locale,
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              AppLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
