import 'package:dart_openai/dart_openai.dart';
import 'package:first_app/main.dart';
import 'package:first_app/models/models.dart';
import 'package:first_app/providers/api_key.dart';
import 'package:first_app/providers/chat_provider.dart';
import 'package:first_app/screens/home_screen.dart';
import 'package:first_app/screens/keyGenerate_screen.dart';
import 'package:first_app/screens/summary_screen.dart';
import 'package:first_app/services/api_services.dart';
import 'package:first_app/widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  bool isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;

  @override
  void initState() {
    _listScrollController = ScrollController();
    textEditingController = TextEditingController();
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _listScrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Widget activePage = ChatScreen();
    // if (_selectedPageIndex == 1) {
    //   activePage = SummaryScreen();
    // }

    //final modelsProvider = Provider.of<ModelsProvider>(context);
    final chatprovider = ref.watch(chatProvider);
    return Scaffold(
      appBar: AppBar(
        elevation: 2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'images/openai_logo.jpg',
              width: 20,
            ),
            const SizedBox(
              width: 8,
            ),
            _selectedPageIndex == 0
                ? const Text("ChatGPT")
                : const Text("Q&A from documents"),
            const SizedBox(
              width: 50,
            ),
          ],
        ),
        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Theme.of(context).colorScheme.onBackground,
            ),
      ),
      drawer: const NavigationDrawerNew(),
      body: _selectedPageIndex == 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    Flexible(
                      child: ListView.builder(
                          controller: _listScrollController,
                          itemCount: chatprovider.length, //chatList.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: ChatWidget(
                                msg: chatprovider[index].msg,
                                // chatList[index].msg,
                                chatIndex: chatprovider[index].chatIndex,
                                //chatList[index].chatIndex,
                              ),
                            );
                          }),
                    ),
                    if (isTyping) ...[
                      const SpinKitThreeBounce(
                        color: Color.fromARGB(255, 247, 242, 242),
                        size: 18,
                      ),
                    ],
                    const SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Material(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: Theme.of(context).colorScheme.onPrimary),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                  child: TextField(
                                focusNode: focusNode,
                                style: Theme.of(context).textTheme.bodyLarge,
                                controller: textEditingController,
                                onSubmitted: (value) async {
                                  await sendMessageFCT();
                                },
                                decoration: InputDecoration.collapsed(
                                  hintText: "Ask me anything!",
                                  hintStyle: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary
                                            .withOpacity(0.3),
                                      ),
                                ),
                              )),
                              IconButton(
                                onPressed: () async {
                                  await sendMessageFCT();
                                },
                                icon: Icon(
                                  Icons.send,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Free Research Preview. Our goal is to make AI systems more natural and safe to interact with. Your feedback will help us improve.',
                        style: Theme.of(context).textTheme.labelSmall!.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SummaryScreen(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        backgroundColor: Theme.of(context).colorScheme.outlineVariant,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/chatIcon.png',
              width: 20,
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'images/loupe.png',
              width: 20,
            ),
            label: 'Summary',
          ),
        ],
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(seconds: 2),
        curve: Curves.easeOut);
  }

  Future<void> sendMessageFCT() async {
    if (isTyping) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Theme.of(context).colorScheme.error,
          content: const Text(
            "You cant send multiple messages at a time",
          ),
        ),
      );
      return;
    }
    if (textEditingController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Please type a message",
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    try {
      String msg = textEditingController.text;
      setState(() {
        isTyping = true;
        ref.watch(chatProvider.notifier).addUserMessage(msg: msg);
        textEditingController.clear();
        focusNode.unfocus();
      });
      // final List<ModelsModel> models = await ApiService.getModels();
      // for (var model in models) {
      //   print(model.root); // Đây là tên của model
      // }
      OpenAI.apiKey = ref.watch(apiKeyProvider);
      await ref
          .watch(chatProvider.notifier)
          .sendMessageAndGetAnswers(msg: msg, chosenModelId: "gpt-3.5-turbo");
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          error.toString(),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ));
    } finally {
      setState(() {
        scrollListToEND();
        isTyping = false;
      });
    }
  }
}

class NavigationDrawerNew extends StatelessWidget {
  const NavigationDrawerNew({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DrawerHeader(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 18),
                  Text(
                    'Chatbox menu!',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.chat_outlined,
                size: 26,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'Chat with me',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24,
                    ),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const ChatScreen()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.logout,
                size: 26,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'Log out',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24,
                    ),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const HomeScreen()));
              },
            ),
            ListTile(
              leading: Icon(
                Icons.key_outlined,
                size: 26,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'giu cho',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 24,
                    ),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const HomeScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }
}
