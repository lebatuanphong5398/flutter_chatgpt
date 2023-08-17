import 'dart:async';
import 'dart:convert';

import 'package:first_app/constants/api_consts.dart';
import 'package:first_app/providers/api_key.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/screens/chat_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.changetheme});
  final void Function() changetheme;
  @override
  ConsumerState<HomeScreen> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final Uri url = Uri.parse('https://platform.openai.com/account/api-keys');
  TextEditingController _controller = TextEditingController();
  bool _onPress = false;
  double _opacity = 0.5;

  Future<void> _getOpenAIKey() async {
    final url = Uri.https(RTDB, 'openai-key.json');
    try {
      final response = await http.get(url);
      if (response.body == 'null') {
        print("null api");
        return;
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      var apiKey = "";
      for (final itemData in listData.entries) {
        apiKey = itemData.value['OpenAIkey'];
        print('apiKey: _________ $apiKey');
      }
      setState(() {
        _controller = TextEditingController(text: apiKey);
        ref.watch(apiKeyProvider.notifier).saveAPIKey(apiKey);
      });
    } catch (e) {
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _getOpenAIKey();
    //print('apiKey: _________ $apiKey');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  var keyCodeStatus = -1;
  Future<int> isCorrectKey(String value) async {
    final url = Uri.https('api.openai.com', 'v1/models');
    return await http.get(url,
        headers: {'Authorization': ' Bearer $value'}).then((response) {
      keyCodeStatus = response.statusCode;
      print('StatusCode: ______________________ ${response.statusCode}');
      return response.statusCode;
    }).catchError((error) => 0);
  }

  // Future generationsimages() async {
  //   final url = Uri.https('api.openai.com', 'v1/images/generations');
  //   var response = await http.post(url,
  //       headers: {
  //         'Authorization': 'Bearer $apiKey',
  //         "Content-Type": "application/json"
  //       },
  //       body: json.encode(
  //           {"prompt": "A cute baby sea otter", "n": 2, "size": "1024x1024"}));
  //   Map jsonResponse = jsonDecode(response.body);
  //   print(jsonResponse["data"][0]["url"]);
  // }

  void _addOpenAIKey(String apikey) async {
    final url = Uri.https(RTDB, 'openai-key.json');
    http.post(url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'OpenAIkey': apikey,
        }));
  }

  Future removeOpenAIKey() async {
    final url = Uri.https(RTDB, 'openai-key.json');
    await http.delete(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(children: [
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
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _controller,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 10 ||
                        value.trim().length > 100) {
                      return 'Must be between 10 and 100 characters.';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    apiKey = value!;
                    ref.watch(apiKeyProvider.notifier).saveAPIKey(value);
                  },
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
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
                    labelStyle:
                        Theme.of(context).textTheme.labelLarge!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
                                  .withOpacity(0.5),
                            ),
                  ),
                ),
              ),
            ),
            // Text(ref.watch(apiKeyProvider)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an API key?",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                ),
                InkWell(
                  onTap: () async {
                    if (await launchUrl(
                      url,
                    )) {
                      debugPrint('succesfully');
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: Text(
                    'Create one now',
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          decoration: TextDecoration.underline,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _onPress = true;
                    _opacity = 0.7;
                  });
                  keyCodeStatus = await isCorrectKey(_controller.text);
                  if (keyCodeStatus == 200) {
                    await removeOpenAIKey();
                    Timer(const Duration(seconds: 5), () {});
                    _addOpenAIKey(_controller.text);
                    _formKey.currentState!.save();
                    //generationsimages();
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
                    Timer(
                        const Duration(seconds: 3),
                        () => Navigator.of(context)
                            .pushReplacement(MaterialPageRoute(
                                builder: (BuildContext context) => ChatScreen(
                                      changetheme: widget.changetheme,
                                    ))));
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Theme.of(context).colorScheme.error,
                        duration: const Duration(seconds: 2),
                        content: const Text("APIKEY wrong."),
                      ),
                    );
                  }
                  setState(() {
                    _onPress = false;
                    _opacity = 0.5;
                  });
                  return;
                }
              },
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(160, 40),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                foregroundColor: Theme.of(context).colorScheme.onBackground,
                elevation: 15.0,
              ),
              child: Text(
                'Submit',
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ),
            if (_onPress) const CircularProgressIndicator(),
          ],
        ),
      ]),
    ));
  }
}
