import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_app/providers/chat_provider.dart';
import 'package:first_app/screens/chat_screen.dart';
import 'package:first_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NavigationDrawerNew extends ConsumerStatefulWidget {
  const NavigationDrawerNew({super.key});

  @override
  ConsumerState<NavigationDrawerNew> createState() =>
      _NavigationDrawerNewState();
}

class _NavigationDrawerNewState extends ConsumerState<NavigationDrawerNew> {
  @override
  Widget build(BuildContext context) {
    dynamic loadedMessages;
    return Drawer(
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
                  'Chat history!',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
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
                      return ListTile(
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
                                color:
                                    Theme.of(context).colorScheme.onBackground,
                                fontSize: 24,
                              ),
                        ),
                        onTap: () async {
                          await ref
                              .watch(chatProvider.notifier)
                              .getchatlist(loadedMessages[index].id);
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (ctx) => const ChatScreen()));
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
                      );
                    },
                  ),
                );
              }),
          const Divider(),
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
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const HomeScreen()));
            },
          ),
          ListTile(
            leading: Icon(
              Icons.delete,
              size: 26,
              color: Theme.of(context).colorScheme.onBackground,
            ),
            title: Text(
              'Clear all chats',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onBackground,
                    fontSize: 24,
                  ),
            ),
            onTap: () {
              for (var element in loadedMessages) {
                FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(element.id)
                    .delete();
              }
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
