import 'package:google_fonts/google_fonts.dart';
import 'package:testapp/providers/models_provider.dart';
//import 'package:testapp/screens/keyGenerate_screen.dart';
//import 'package:testapp/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'providers/chat_provider.dart';
//import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:provider/provider.dart';
import 'constants/constants.dart';
import 'screens/chat_screen.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 117, 222, 182),
  ),
  textTheme: GoogleFonts.latoTextTheme(),
);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ModelsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        home: const ChatScreen(),
      ),
    );
  }
}
