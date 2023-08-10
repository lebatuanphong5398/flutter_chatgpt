// import 'dart:async';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:first_app/screens/chat_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';

// class GenerateKey extends StatefulWidget {
//   const GenerateKey({super.key});
//   @override
//   State<GenerateKey> createState() => _GenerateKeyState();
// }

// class _GenerateKeyState extends State<GenerateKey> {
//   TextEditingController pasteController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     getData();
//   }

//   getData() async {

//   }

//   @override
//   void dispose() {
//     pasteController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final Uri _Url = Uri.parse('https://platform.openai.com/account/api-keys');
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("API KEY"),
//         titleTextStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
//               color: Theme.of(context).colorScheme.onBackground,
//               fontSize: 20,
//             ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Container(
//           padding: const EdgeInsets.only(left: 40.0, right: 40.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(
//                 height: 20.0,
//               ),
//               Text(
//                 'Generate a',
//                 style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                       color: Theme.of(context).colorScheme.onBackground,
//                       fontSize: 20,
//                     ),
//               ),
//               const SizedBox(
//                 height: 3.0,
//               ),
//               Text(
//                 'API Key',
//                 style: Theme.of(context).textTheme.titleMedium!.copyWith(
//                       color: Theme.of(context).colorScheme.onBackground,
//                       fontSize: 22,
//                     ),
//               ),
//               const SizedBox(
//                 height: 15.0,
//               ),
//               Text(
//                 'To chat with me, get an API key from OpenAI. Simply click this button and follow the steps to generate a key. '
//                 'Then enter the key in our app to start chatting',
//                 style: Theme.of(context).textTheme.labelLarge!.copyWith(
//                       color: Theme.of(context).colorScheme.onBackground,
//                     ),
//               ),
//               const SizedBox(
//                 height: 20.0,
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (await launchUrl(
//                     _Url,
//                   )) {
//                     debugPrint('succesfully');
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   fixedSize: const Size(160, 40),
//                   backgroundColor:
//                       Theme.of(context).colorScheme.primaryContainer,
//                   foregroundColor:
//                       Theme.of(context).colorScheme.onPrimaryContainer,
//                   elevation: 15.0,
//                 ),
//                 child: Text(
//                   'Begin',
//                   style: Theme.of(context).textTheme.labelLarge!.copyWith(
//                         color: Theme.of(context).colorScheme.tertiary,
//                       ),
//                 ),
//               ),
//               const SizedBox(
//                 height: 40.0,
//               ),

//               Text(
//                 'After copied your Api key paste and save it here',
//                 style: Theme.of(context).textTheme.labelLarge!.copyWith(
//                       color: Theme.of(context).colorScheme.onBackground,
//                     ),
//               ),

//               const SizedBox(
//                 height: 20.0,
//               ),
//               // Container(
//               //   padding: EdgeInsets.all(15.0),
//               //   child: Text('API Key'),
//               //   decoration: BoxDecoration(
//               //     border: Border.all(
//               //       color: Colors.deepOrange,
//               //       width: 2.0
//               //     ),
//               //     borderRadius: BorderRadius.circular(20.0)
//               //   ),
//               // ),
//               TextField(
//                 decoration: InputDecoration(
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(20.0),
//                     borderSide: BorderSide(
//                       color: Theme.of(context).colorScheme.onPrimaryContainer,
//                     ),
//                   ),
//                   floatingLabelStyle:
//                       Theme.of(context).textTheme.labelLarge!.copyWith(
//                             color: Theme.of(context).colorScheme.onBackground,
//                           ),
//                   labelText: 'Paste your API Key',
//                   labelStyle: Theme.of(context).textTheme.labelLarge!.copyWith(
//                         color: Theme.of(context)
//                             .colorScheme
//                             .onBackground
//                             .withOpacity(0.5),
//                       ),
//                 ),
//                 controller: pasteController,
//               ),
//               const SizedBox(
//                 height: 20.0,
//               ),

//               ElevatedButton(
//                 onPressed: () async {
//                   setState(() {
//                     Api_key = pasteController.text;
//                     print(Api_key);
//                     Timer(
//                         const Duration(seconds: 3),
//                         () => Navigator.of(context).pushReplacement(
//                             MaterialPageRoute(
//                                 builder: (BuildContext context) =>
//                                     const ChatScreen())));
//                   });
//                   SharedPreferences prefs =
//                       await SharedPreferences.getInstance();
//                   prefs.setString('ApiKey', Api_key);
//                   print(ApiKey);
//                   ScaffoldMessenger.of(context).clearSnackBars();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       behavior: SnackBarBehavior.floating,
//                       backgroundColor:
//                           Theme.of(context).colorScheme.onPrimaryContainer,
//                       duration: const Duration(seconds: 3),
//                       content: const Text(
//                           "Success. Your OpenAI API key has been saved successfully. You wont need to enter it again in the future."),
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   fixedSize: const Size(160, 40),
//                   backgroundColor:
//                       Theme.of(context).colorScheme.primaryContainer,
//                   foregroundColor:
//                       Theme.of(context).colorScheme.onPrimaryContainer,
//                   elevation: 15.0,
//                 ),
//                 child: Text(
//                   'Save',
//                   style: Theme.of(context).textTheme.labelLarge!.copyWith(
//                         color: Theme.of(context).colorScheme.tertiary,
//                       ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
