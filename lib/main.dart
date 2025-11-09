import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/category_provider.dart';
import 'providers/phrase_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/ai_provider_offline.dart';
import 'providers/ai_provider_online.dart';
import 'providers/connectivity_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load environment variables
  await dotenv.load(fileName: ".env");

  //final dbService = DatabaseService();
  //await dbService.resetDatabase(); // This deletes and recreates the DB


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => PhraseProvider()),
        ChangeNotifierProvider(create: (_) => AIProviderOnline()),
        ChangeNotifierProvider(create: (_) => AIProviderOffline()),
      ],
      child: const EduNovaApp(),
    ),
  );
}
