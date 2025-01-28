import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'core/auth/services/auth_service.dart';
import 'core/services/navigation_service.dart';
import 'core/auth/providers/auth_provider.dart';
import 'core/config/app_config.dart';
import 'core/config/route_config.dart';
import 'core/config/theme_config.dart';
import 'core/config/provider_config.dart';
import 'core/config/env.dart';
import 'core/auth/screens/login_screen.dart';
import 'features/dashboard/screens/machine_dashboard_screen.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
    printTime: true,
  ),
);

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Catch all errors, including those in the zone
  runZonedGuarded(() async {
    try {
      logger.i('Starting application initialization');
      WidgetsFlutterBinding.ensureInitialized();

      // Set up error handling for Flutter errors
      FlutterError.onError = (FlutterErrorDetails details) {
        logger.e('Flutter error: ${details.exception}',
            error: details.exception, stackTrace: details.stack);
      };

      logger.i('Attempting to initialize Supabase...');
      try {
        await Supabase.initialize(
          url: Env.supabaseUrl,
          anonKey: Env.supabaseAnonKey,
        );
        logger.i('Supabase initialized successfully');
      } catch (e, stackTrace) {
        logger.e('Failed to initialize Supabase',
            error: e, stackTrace: stackTrace);
        runApp(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'Initialization Error',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Failed to connect to the server. Please check your internet connection and try again.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                      if (e.toString().isNotEmpty) ...[
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            e.toString(),
                            style: TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Restart the app
                          main();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        return;
      }

      logger.i('Initializing services...');
      final supabase = Supabase.instance.client;
      final authService = AuthService(supabase);
      await authService.initialize(); // Initialize AuthService first

      final navigationService = NavigationService();
      final themeConfig = ThemeConfig();
      final routeConfig = RouteConfig();
      final providerConfig = ProviderConfig();

      logger.i('Creating AppConfig...');
      final appConfig = AppConfig(
        themeConfig: themeConfig,
        routeConfig: routeConfig,
        providerConfig: providerConfig,
        navigationService: navigationService,
      );

      logger.i('Running app with providers...');
      runApp(
        MultiProvider(
          providers: [
            ...ProviderConfig.providers,
            Provider<AppConfig>.value(value: appConfig),
          ],
          child: MyApp(appConfig: appConfig),
        ),
      );
    } catch (e, stackTrace) {
      logger.e('Fatal error during initialization',
          error: e, stackTrace: stackTrace);
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'Fatal Error',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'A fatal error occurred while starting the app.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    if (e.toString().isNotEmpty) ...[
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          e.toString(),
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        // Restart the app
                        main();
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }, (error, stack) {
    logger.e('Uncaught error in zone', error: error, stackTrace: stack);
  });
}

class MyApp extends StatelessWidget {
  final AppConfig appConfig;
  final _logger = logger;

  MyApp({super.key, required this.appConfig});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALD Machine Control',
      theme: ThemeConfig.teslaTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          if (authProvider.isLoading) {
            return _buildLoadingScreen();
          }

          if (authProvider.isAuthenticated) {
            if (!authProvider.isApproved()) {
              return _buildPendingApprovalScreen();
            }
            return _buildAuthenticatedScreen();
          } else {
            return LoginScreen();
          }
        },
      ),
      routes: RouteConfig.routes,
      onGenerateRoute: RouteConfig.generateRoute,
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Color(0xFF1A1A1A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/atomicoat_app_icon.png',
              width: 120,
              height: 120,
            ),
            SizedBox(height: 32),
            Text(
              'AtomiCoat',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ),
            SizedBox(height: 24),
            Container(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    ThemeConfig.teslaTheme.primaryColor),
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedScreen() {
    return MachineDashboard();
  }

  Widget _buildPendingApprovalScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.hourglass_empty, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Pending Approval',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your account is pending administrator approval.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final authProvider = Provider.of<AuthProvider>(
                  navigatorKey.currentContext!,
                  listen: false,
                );
                await authProvider.signOut();
              },
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }
}
