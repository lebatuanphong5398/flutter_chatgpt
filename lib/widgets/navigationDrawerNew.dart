import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/providers/chat_provider.dart';
import 'package:first_app/providers/image_provider.dart';
import 'package:first_app/providers/summary_provider.dart';
import 'package:first_app/screens/chat_screen.dart';
import 'package:first_app/screens/home_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

class NavigationDrawerNew extends ConsumerStatefulWidget {
  const NavigationDrawerNew(
      {super.key, required this.selectPage, required this.changetheme});

  final void Function(int) selectPage;
  final void Function() changetheme;
  @override
  ConsumerState<NavigationDrawerNew> createState() =>
      _NavigationDrawerNewState();
}

class _NavigationDrawerNewState extends ConsumerState<NavigationDrawerNew> {
  @override
  Widget build(BuildContext context) {
    dynamic loadedMessages;
    dynamic loadedimages;
    dynamic loadedsmr;
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 150,
            child: DrawerHeader(
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
                    'Chat history!',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('conversations')
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),
              builder: (ctx, chatSnapshots) {
                if (chatSnapshots.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!chatSnapshots.hasData ||
                    chatSnapshots.data!.docs.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        'No history chat.',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 24,
                            ),
                      ),
                    ),
                  );
                }

                loadedMessages = chatSnapshots.data!.docs;

                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 40,
                      left: 13,
                      right: 13,
                    ),
                    itemCount: loadedMessages.length,
                    itemBuilder: (ctx, index) {
                      return Container(
                        constraints: const BoxConstraints(maxHeight: 50),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.chat_outlined,
                            size: 26,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          title: Text(
                            'Chat history',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 16,
                                ),
                          ),
                          onTap: () async {
                            await ref
                                .watch(chatProvider.notifier)
                                .getchatlist(loadedMessages[index].id);
                            Navigator.of(context)
                                .pushReplacement(MaterialPageRoute(
                                    builder: (ctx) => ChatScreen(
                                          changetheme: widget.changetheme,
                                        )));
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('conversations')
                                  .doc(loadedMessages[index].id)
                                  .delete();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
          const Divider(),
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('images')
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),
              builder: (ctx, chatSnapshots) {
                if (chatSnapshots.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!chatSnapshots.hasData ||
                    chatSnapshots.data!.docs.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        'No history image.',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 24,
                            ),
                      ),
                    ),
                  );
                }

                loadedimages = chatSnapshots.data!.docs;

                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 40,
                      left: 13,
                      right: 13,
                    ),
                    itemCount: loadedimages.length,
                    itemBuilder: (ctx, index) {
                      return Container(
                        constraints: const BoxConstraints(maxHeight: 50),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.picture_in_picture,
                            size: 26,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          title: Text(
                            'Image history',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 16,
                                ),
                          ),
                          onTap: () async {
                            await ref
                                .watch(imageProvider.notifier)
                                .getchatlist(loadedimages[index].id);
                            widget.selectPage(2);
                            Navigator.of(context).pop();
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('images')
                                  .doc(loadedimages[index].id)
                                  .delete();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
          const Divider(),
          StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('Summary').snapshots(),
              builder: (ctx, chatSnapshots) {
                if (chatSnapshots.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!chatSnapshots.hasData ||
                    chatSnapshots.data!.docs.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        'No history summary.',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 24,
                            ),
                      ),
                    ),
                  );
                }

                loadedsmr = chatSnapshots.data!.docs;

                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      bottom: 40,
                      left: 13,
                      right: 13,
                    ),
                    itemCount: loadedsmr.length,
                    itemBuilder: (ctx, index) {
                      return Container(
                        constraints: const BoxConstraints(maxHeight: 50),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.text_format,
                            size: 26,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                          title: Text(
                            'Summary history',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground,
                                  fontSize: 16,
                                ),
                          ),
                          onTap: () async {
                            final data = await FirebaseFirestore.instance
                                .collection('Summary')
                                .doc(loadedsmr[index].id)
                                .get();
                            File file = File(data["filepath"]);
                            //print("------------------${data["filepath"]}");
                            await ref
                                .watch(sMRProvider.notifier)
                                .getchatlist(loadedsmr[index].id, file);
                            widget.selectPage(1);
                            Navigator.of(context).pop();
                          },
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              FirebaseFirestore.instance
                                  .collection('Summary')
                                  .doc(loadedimages[index].id)
                                  .delete();
                            },
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
          const Divider(),
          Container(
            constraints: const BoxConstraints(maxHeight: 45),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                size: 22,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'Log out',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 20,
                    ),
              ),
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => HomeScreen(
                          changetheme: widget.changetheme,
                        )));
              },
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 45),
            child: ListTile(
              leading: Icon(
                Icons.delete,
                size: 22,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'Clear all chats',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 20,
                    ),
              ),
              onTap: () {
                if (loadedMessages != null) {
                  for (var element in loadedMessages) {
                    FirebaseFirestore.instance
                        .collection('conversations')
                        .doc(element.id)
                        .delete();
                  }
                }

                if (loadedsmr != null) {
                  for (var element in loadedsmr) {
                    FirebaseFirestore.instance
                        .collection('Summary')
                        .doc(element.id)
                        .delete();
                  }
                }
                if (loadedimages != null) {
                  for (var element in loadedimages) {
                    FirebaseFirestore.instance
                        .collection('images')
                        .doc(element.id)
                        .delete();
                  }
                }
                setState(() {});
              },
            ),
          ),
          Container(
            constraints: const BoxConstraints(maxHeight: 45),
            child: ListTile(
              leading: Icon(
                Icons.settings,
                size: 22,
                color: Theme.of(context).colorScheme.onBackground,
              ),
              title: Text(
                'Change theme',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground,
                      fontSize: 20,
                    ),
              ),
              onTap: () {
                widget.changetheme();
              },
            ),
          ),
        ],
      ),
    );
  }
}
