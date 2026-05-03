import 'package:english_learning_sales/pages/dashboard_page.dart';
import 'package:english_learning_sales/pages/login_page.dart';
import 'package:english_learning_sales/provider/auth_provider.dart';
import 'package:english_learning_sales/provider/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  await dotenv.load(fileName: "firebase_keys.env");
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN'],
      databaseURL: dotenv.env['FIREBASE_DB_URL'],
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'],
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'],
    ),
  );
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HiSir - Sales Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user != null) {
          return Builder(
            builder: (context) {
              final user = ref.watch(salesAgentDataProvider);

              if (user.isLoading) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return DashboardPage();
            },
          );
        }
        return const SalesmanLoginPage();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, stack) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}


