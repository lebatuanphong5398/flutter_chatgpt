// import 'package:first_app/models/models.dart';
// import 'package:first_app/services/api_services.dart';
// import 'package:first_app/widgets/text_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:first_app/widgets/text_widget.dart';

// class DropDownWidget extends StatefulWidget {
//   const DropDownWidget({Key? key}) : super(key: key);

//   @override
//   State<DropDownWidget> createState() => _DropDownWidgetState();
// }

// class _DropDownWidgetState extends State<DropDownWidget> {
//   String? currentModels;

//   @override
//   Widget build(BuildContext context) {
//     currentModels = "gpt-3.5-turbo";
//     return FutureBuilder<List<ModelsModel>>(
//         future: modelsProvider.getAllModels(),
//         builder: (context, snapshot) {
//           if (snapshot.hasError) {
//             return Center(
//               child: TextWidget(
//                 label: snapshot.error.toString(),
//               ),
//             );
//           }
//           return snapshot.data == null || snapshot.data!.isEmpty
//               ? SizedBox.shrink()
//               : FittedBox(
//                   child: DropdownButton(
//                     dropdownColor: scaffoldBackgroundColor,
//                     iconEnabledColor: Colors.white,
//                     items: List<DropdownMenuItem<String>>.generate(
//                       snapshot.data!.length,
//                       (index) => DropdownMenuItem(
//                           value: snapshot.data![index].id,
//                           child: TextWidget(
//                             label: snapshot.data![index].id,
//                             fontSize: 15.0,
//                           )),
//                     ),
//                     value: currentModels,
//                     onChanged: (value) {
//                       setState(() {
//                         currentModels = value.toString();
//                       });
//                       modelsProvider.setCurrentModel(
//                         value.toString(),
//                       );
//                     },
//                   ),
//                 );
//         });
//   }
// }
