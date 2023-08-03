import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:first_app/screens/chat_screen.dart';
import 'package:first_app/widgets/checkAPI.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController pasteController = TextEditingController();
  String apiKey = '';
  bool _onPress = false;
  bool? _loginSuccess;
  double _opacity = 0.5;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(_opacity),
          BlendMode.darken, // Chế độ làm tối
        ),
        child: Image.asset(
          'assets/images/brycenvietnamlogo.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill,
        ),
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/chatboxlogo.png',
            width: 200,
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60.0),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                floatingLabelStyle:
                    Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                labelText: 'Enter your API Key',
                labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withOpacity(0.5),
                    ),
              ),
              controller: pasteController,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            // onPressed: () async {
            //   setState(() {
            //     apiKey = pasteController.text;
            //     print(apiKey);
            //     Timer(

            //         const Duration(seconds: 3),
            //         () => Navigator.of(context).pushReplacement(
            //             MaterialPageRoute(
            //                 builder: (BuildContext context) =>
            //                     const ChatScreen())));
            //   });
            //   SharedPreferences prefs = await SharedPreferences.getInstance();
            //   prefs.setString('ApiKey', apiKey);
            //   print(apiKey);

            // ScaffoldMessenger.of(context).clearSnackBars();
            // ScaffoldMessenger.of(context).showSnackBar(
            //   SnackBar(
            //     behavior: SnackBarBehavior.floating,
            //     backgroundColor:
            //         Theme.of(context).colorScheme.onPrimaryContainer,
            //     duration: const Duration(seconds: 3),
            //     content: const Text(
            //         "Success. Your OpenAI API key has been saved successfully. You wont need to enter it again in the future."),
            //   ),
            //   );
            // },
            onPressed: () async {
              setState(() {
                _onPress = true;
                _opacity = 0.7;
              });
              await Future.delayed(const Duration(seconds: 2));
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor:
                      Theme.of(context).colorScheme.onPrimaryContainer,
                  duration: const Duration(seconds: 3),
                  content: const Text(
                      "Success. Your OpenAI API key has been saved successfully. You wont need to enter it again in the future."),
                ),
              );
              apiKey = pasteController.text;
              print(apiKey);
              Timer(
                  const Duration(seconds: 3),
                  () => Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => const ChatScreen())));

              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('ApiKey', apiKey);
              print(apiKey);
              setState(() {
                _onPress = false;
                _opacity = 0.5;
              });
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(160, 40),
              backgroundColor: Theme.of(context).colorScheme.background,
              foregroundColor: Theme.of(context).colorScheme.onBackground,
              elevation: 15.0,
            ),
            child: Text(
              'Submit',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
            ),
          ),
          if (_onPress) const CircularProgressIndicator(),
        ],
      ),
    ]));
  }
}
