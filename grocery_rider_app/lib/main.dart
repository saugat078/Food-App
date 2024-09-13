import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grocery_rider_app/provider/dark_theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:grocery_rider_app/Auth/login.dart';
import 'package:grocery_rider_app/Auth/register.dart';
import 'package:grocery_rider_app/firebase_options.dart';
import 'package:grocery_rider_app/pages/order_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DarkThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.setDarkTheme =
        await themeChangeProvider.darkThemePrefs.getTheme();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DarkThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'OSM Flutter Application',
          theme: themeProvider.getDarkTheme ? ThemeData.dark() : ThemeData.light(),
          initialRoute: '/LoginScreen',
          routes: {
            '/LoginScreen': (context) => LoginScreen(),
            '/RegisterScreen': (context) => RegisterScreen(),
            '/orders': (context) => OrdersList(),
          },
        );
      },
    );
  }
}