import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'dart:typed_data';

class ImageWidget extends StatelessWidget {
  const ImageWidget({super.key, required this.msg, required this.chatIndex});

  final String msg;
  final int chatIndex;

  @override
  Widget build(BuildContext context) {
    void saveImageToGallery(String imageUrl) async {
      final response = await http.get(Uri.parse(msg));
      final Uint8List bytes = response.bodyBytes;
      final result =
          await ImageGallerySaver.saveImage(Uint8List.fromList(bytes));

      if (result['isSuccess']) {
        print('Image saved to gallery.');
      } else {
        print('Error saving image: ${result['errorMessage']}');
      }
    }
    //   void _addItem() async {
    //   final newItem = await Navigator.of(context).push<GroceryItem>(
    //     MaterialPageRoute(
    //       builder: (ctx) => const NewItem(),
    //     ),
    //   );

    //   if (newItem == null) {
    //     return;
    //   }

    //   setState(() {
    //     _groceryItems.add(newItem);
    //   });
    // }

    Widget? content;
    if (chatIndex == 0) {
      content = Text(msg,
          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: Theme.of(context).colorScheme.onBackground,
                fontSize: 16,
              ));
    } else {
      content = InkWell(
        onTap: () async {
          bool check = await showDownloadConfirmationDialog(context);
          if (check) {
            saveImageToGallery(msg);
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
                duration: const Duration(seconds: 1),
                content: const Text("Successful download."),
              ),
            );
          }

          return;
        },
        child: Image.network(
          msg,
        ),
      );
    }

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
                    Expanded(child: content),
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

Future<bool> showDownloadConfirmationDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Download Confirmation'),
        content: const Text('Do you want to download the file?'),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
            onPressed: () {
              Navigator.of(context).pop(false); // Không tải xuống
            },
          ),
          TextButton(
            child: Text(
              'Download',
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
            ),
            onPressed: () {
              Navigator.of(context).pop(true); // Đồng ý tải xuống
            },
          ),
        ],
      );
    },
  );
}
