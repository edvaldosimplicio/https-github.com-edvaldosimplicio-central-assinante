import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/home_provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProxyProvider<AuthProvider, HomeProvider>(
          create: (_) => HomeProvider(ApiService(baseUrl: AppConfig.defaultBaseUrl)),
          update: (context, auth, previous) {
            if (auth.isLoggedIn) {
              final api = ApiService(
                baseUrl: AppConfig.defaultBaseUrl,
                token: auth.token,
                provedorId: auth.provedorConfig?.slug,
              );
              final provider = HomeProvider(api);
              if (previous?.conexao == null) {
                provider.loadHomeData();
              }
              return provider;
            }
            return previous ?? HomeProvider(ApiService(baseUrl: AppConfig.defaultBaseUrl));
          },
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final theme = auth.provedorConfig?.theme ?? AppTheme();
          return MaterialApp(
            title: 'Central do Assinante',
            debugShowCheckedModeBanner: false,
            theme: theme.toThemeData(),
            initialRoute: '/login',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/main': (context) => const MainShell(),
            },
          );
        },
      ),
    );
  }
}
