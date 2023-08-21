import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';

class ChatWidget extends StatelessWidget {
  const ChatWidget({super.key, required this.msg, required this.chatIndex});

  final String msg;
  final int chatIndex;

  @override
  Widget build(BuildContext context) {
    print(msg);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      chatIndex == 0
                          ? 'assets/images/person.png'
                          : 'assets/images/chat_logo.png',
                      height: 30.0,
                      width: 30.0,
                    ),
                    const SizedBox(
                      width: 10.0,
                    ),
                    Expanded(
                      child: chatIndex == 0
                          ? Text(msg,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 16,
                                  ))
                          : DefaultTextStyle(
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 16,
                                  ),
                              child: AnimatedTextKit(
                                isRepeatingAnimation: false,
                                repeatForever: true,
                                displayFullTextOnTap: true,
                                totalRepeatCount: 0,
                                stopPauseOnTap: false,
                                animatedTexts: [
                                  TyperAnimatedText(
                                    msg.trim(),
                                  ),
                                ],
                              )),
                    ),
                  ],
                ),
                // const SizedBox(
                //   height: 5.0,
                // ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
