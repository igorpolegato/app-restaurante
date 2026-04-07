import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/item_repository.dart';
import 'data/repositories/order_repository.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/menu_provider.dart';
import 'presentation/providers/order_provider.dart';
import 'presentation/providers/session_provider.dart';
import 'presentation/screens/customer/customer_home_screen.dart';
import 'presentation/screens/customer/identification_screen.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const QuiosqueApp());
}

class QuiosqueApp extends StatelessWidget {
  const QuiosqueApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiClient = ApiClient();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => MenuProvider(
            ItemRepository(apiClient),
            CategoryRepository(apiClient),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(
            OrderRepository(apiClient),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Quiosque',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/identify': (_) => const IdentificationScreen(),
          '/customer': (_) => const CustomerHomeScreen(),
        },
      ),
    );
  }
}
