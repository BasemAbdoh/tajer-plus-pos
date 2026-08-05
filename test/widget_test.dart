import 'package:flutter_test/flutter_test.dart';
import 'package:shop_prices/main.dart';
import 'package:shop_prices/database/product_data_source.dart';
import 'package:shop_prices/database/category_data_source.dart';
import 'package:shop_prices/database/exchange_rate_data_source.dart';
import 'package:shop_prices/database/price_history_data_source.dart';
import 'package:shop_prices/repositories/product_repository.dart';
import 'package:shop_prices/repositories/category_repository.dart';
import 'package:shop_prices/repositories/exchange_rate_repository.dart';
import 'package:shop_prices/repositories/price_history_repository.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    final productDataSource = ProductDataSource();
    final categoryDataSource = CategoryDataSource();
    final exchangeRateDataSource = ExchangeRateDataSource();
    final priceHistoryDataSource = PriceHistoryDataSource();

    final productRepository = ProductRepository(productDataSource);
    final categoryRepository = CategoryRepository(categoryDataSource);
    final exchangeRateRepository = ExchangeRateRepository(exchangeRateDataSource);
    final priceHistoryRepository = PriceHistoryRepository(priceHistoryDataSource);

    await tester.pumpWidget(
      MyApp(
        productRepository: productRepository,
        categoryRepository: categoryRepository,
        exchangeRateRepository: exchangeRateRepository,
        priceHistoryRepository: priceHistoryRepository,
      ),
    );

    expect(find.byType(MyApp), findsOneWidget);
  });
}
