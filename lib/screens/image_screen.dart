import 'package:dart_openai/dart_openai.dart';
import 'package:first_app/providers/api_key.dart';
import 'package:first_app/providers/image_provider.dart';
import 'package:first_app/screens/chat_screen.dart';
import 'package:first_app/widgets/image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class ImageScreen extends ConsumerStatefulWidget {
  const ImageScreen({super.key});

  @override
  ConsumerState<ImageScreen> createState() {
    return _ImageScreenState();
  }
}

class _ImageScreenState extends ConsumerState<ImageScreen> {
  bool isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  String chatid = uuid.v4();

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

  @override
  Widget build(BuildContext context) {
    var imageprovider = ref.watch(imageProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          Flexible(
            child: ListView.builder(
                controller: _listScrollController,
                itemCount: imageprovider.length, //chatList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ImageWidget(
                      msg: imageprovider[index].msg,
                      // chatList[index].msg,
                      chatIndex: imageprovider[index].chatIndex,
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
                side:
                    BorderSide(color: Theme.of(context).colorScheme.onPrimary),
                borderRadius: BorderRadius.circular(10.0),
              ),
              color: Theme.of(context).colorScheme.onTertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                        child: TextField(
                      focusNode: focusNode,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.background,
                          ),
                      controller: textEditingController,
                      onSubmitted: (value) async {
                        await sendMessageFCT();
                      },
                      decoration: InputDecoration.collapsed(
                        hintText: "What would you like me to draw?",
                        hintStyle:
                            Theme.of(context).textTheme.bodyLarge!.copyWith(
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
                        color: Theme.of(context).colorScheme.onPrimary,
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
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void scrollListToEND() {
    _listScrollController.animateTo(
        _listScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
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
        ref
            .watch(imageProvider.notifier)
            .addUserMessage(msg: msg, chatid: chatid);
        textEditingController.clear();
        focusNode.unfocus();
      });

      OpenAI.apiKey = ref.watch(apiKeyProvider);
      await ref.watch(imageProvider.notifier).sendMessageAndGetImage(
          msg: msg, chosenModelId: "gpt-3.5-turbo", chatid: chatid);
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
