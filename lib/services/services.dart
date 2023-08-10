// import 'package:first_app/widgets/drop_down.dart';
// import 'package:flutter/material.dart';
// import 'package:first_app/widgets/text_widget.dart';


// class Services {
//   static Future<void> showModalSheet({required BuildContext context}) async {
//     await showModalBottomSheet(
//         shape: const RoundedRectangleBorder(
//             borderRadius: BorderRadius.vertical(
//           top: Radius.circular(20.0),
//         )),
//         backgroundColor: const Color.fromARGB(255, 53, 23, 234),
//         context: context,
//         builder: (context) {
//           return const Padding(
//             padding: EdgeInsets.all(20.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Flexible(
//                   child: TextWidget(
//                     label: 'Chosen Model: ',
//                     fontSize: 16.0,
//                   ),
//                 ),
//                 Flexible(
//                   flex: 2,
//                   child: DropDownWidget(),
//                 ),
//               ],
//             ),
//           );
//         });
//   }
// }
