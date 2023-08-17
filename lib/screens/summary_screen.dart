import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:first_app/constants/api_consts.dart';
import 'package:first_app/providers/summary_provider.dart';
import 'package:first_app/screens/chat_screen.dart';
import 'package:first_app/widgets/chat_widget.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart' hide OpenAI;

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  PlatformFile? file;
  late RetrievalQAChain retrievalQA;
  dynamic embeddings;
  dynamic textsWithSources;
  dynamic docSearch;
  var _responsedAnswer = '';
  var _enteredQuestion = '';
  void _filePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        file = result.files.first;
        ref.watch(sMRProvider.notifier).addfile(file: File(file!.path!));
      });
    } else {
      // User canceled the picker
    }
  }

  Future<RetrievalQAChain> loadFile() async {
    try {
      var loader = TextLoader(file!.path!);
      loader.load().then((value) {
        const textSplitter = RecursiveCharacterTextSplitter(
          chunkSize: 500,
          chunkOverlap: 0,
        );
        final docChunks = textSplitter.splitDocuments(value);
        textsWithSources = docChunks.map(
          (e) {
            return e.copyWith(
              metadata: {...e.metadata, 'source': '${docChunks.indexOf(e)}-pl'},
            );
          },
        ).toList();
      });
    } catch (e) {
      print(e.toString());
    }

    embeddings = OpenAIEmbeddings(apiKey: apiKey);
    //print(textsWithSources);
    var docSearch = await MemoryVectorStore.fromDocuments(
            documents: textsWithSources, embeddings: embeddings)
        .then((value) {
      print('docSearch:_________________ ${value.memoryVectors.first}');
      return value;
    }).catchError((err) {
      setState(() {
        _responsedAnswer = err.toString();
      });
      return MemoryVectorStore(embeddings: embeddings);
    });

    final llm =
        ChatOpenAI(apiKey: apiKey, model: 'gpt-3.5-turbo', temperature: 0.5);
    final qaChain = OpenAIQAWithSourcesChain(llm: llm);
    final docPrompt = PromptTemplate.fromTemplate(
      '''You will be given a text document\n Answer based on the language of the question \n If you cannot find an answer related to the text, answer:"Không có dữ liệu về câu hỏi trong tài liệu!". '
        .\ncontent: {page_content}\nSource: {source}
        ''',
    );
    final finalQAChain = StuffDocumentsChain(
      llmChain: qaChain,
      documentPrompt: docPrompt,
    );

    return RetrievalQAChain(
      retriever: docSearch.asRetriever(),
      combineDocumentsChain: finalQAChain,
    );
  }

  Future getResponsive() async {
    print("--------${retrievalQA.memory}");
    final res = await retrievalQA("câu chuyện kể về ai");
    print("______________________$res");
    print("---------------${res['statusCode']}");
    print(res["result"]);
  }
  //   final res = await retrievalQA("Bác Hồ là ai");
  //   if (res['statusCode'] == 429) {
  //     _responsedAnswer =
  //         'Bạn đã giữ quá nhiều yêu cầu(Tối Tối đa 3 yêu cầu/phút), hãy thử lại sau 20s.';
  //     print("__________$_responsedAnswer");
  //     //chatConversation.add({'Ai': _responsedAnswer.trim()});
  //     //isLoading = false;
  //   } else {
  //     setState(() {
  //       print(res.toString());
  //       _responsedAnswer = res['result'].toString();
  //       print("__________$_responsedAnswer");
  //       //chatConversation.add({'Ai': _responsedAnswer.trim()});
  //       //isLoading = false;
  //     });
  //   }
  // } catch (err) {
  //   {
  //     if (err.toString().contains('statusCode: 429')) {
  //       setState(() {
  //         _responsedAnswer =
  //             'Tài khoản của bạn bị giới hạn 3 req/min, hãy nâng cấp hoặc thử lại sau 20s.';
  //         // chatConversation.add({'Ai': _responsedAnswer.trim()});
  //         // isLoading = false;
  //       });
  //     } else {
  //       setState(() {
  //         _responsedAnswer =
  //             'Xin chào, hãy đặt các câu hỏi liên quan đến tài liệu đã cung cấp. ${err.toString()}';
  //         // chatConversation.add({'Ai': _responsedAnswer.trim()});
  //         // isLoading = false;
  //       });
  //     }
  //   }
  // }
  // print("__________$_responsedAnswer");

  // void _filePicker() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles();

  //   if (result != null) {
  //     setState(() {
  //       file = result.files.first;
  //     });
  //   } else {
  //     // User canceled the picker
  //   }
  // }

  // Future loaderFile() async {
  //   try {
  //     var loader = TextLoader(file!.path!);
  //     final documents = await loader.load();
  //     //print(documents.length);
  //     const textSplitter = RecursiveCharacterTextSplitter(
  //       chunkSize: 800,
  //       chunkOverlap: 20,
  //     );
  //     final texts = textSplitter.splitDocuments(documents);
  //     final textsWithSources = texts.map((d) {
  //       final i = texts.indexOf(d);
  //       return d.copyWith(metadata: {...d.metadata, 'source': '$i-pl'});
  //     }).toList();
  //     //print(textsWithSources);
  //     final llm = ChatOpenAI(
  //       apiKey: apiKey,
  //       model: 'gpt-3.5-turbo-0613',
  //       temperature: 0.5,
  //     );
  //     final embeddings = OpenAIEmbeddings(apiKey: apiKey);
  //     final docSearch = await MemoryVectorStore.fromDocuments(
  //       documents: textsWithSources,
  //       embeddings: embeddings,
  //     );
  //     //print(docSearch.memoryVectors.last.content);
  //     final qaChain = OpenAIQAWithSourcesChain(llm: llm);
  //     final docPrompt = PromptTemplate.fromTemplate(
  //       '''Hãy sử dụng nội dung của tôi đã cung cấp trong file text để trả lời các câu hỏi bằng tiếng Việt.\nLưu ý: Nếu không tìm thấy câu trả lời trong nội dung đã cung cấp, hãy thông báo "Thông tin không có trong tài liệu đã cung cung cấp ".
  //       Nếu câu hỏi là các câu tương tự như: 'Xin chào', 'Hello'... hãy phản hồi: 'Xin chào, hãy đặt các câu hỏi liên quan đến tài liệu đã cung cấp.'.
  //       .\ncontent: {page_content}\nSource: {source}
  //       ''',
  //     );
  //     final finalQAChain = StuffDocumentsChain(
  //       llmChain: qaChain,
  //       documentPrompt: docPrompt,
  //     );

  //     final retrievalQA = RetrievalQAChain(
  //       retriever: docSearch.asRetriever(),
  //       combineDocumentsChain: finalQAChain,
  //     );

  //     const query = 'Đoạn văn trên nói về vấn đề gì?';
  //     final res = await retrievalQA(query);

  //     print("---------------${res['statusCode']}");
  //     print(res["result"]);
  //     //print("----------------$res");
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }
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
    var smrprovider = ref.watch(sMRProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.all(12),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          _filePicker();
                        },
                        child: Text(
                          'Select File',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer),
                        ),
                      ),
                      const SizedBox(height: 8),
                      smrprovider.isEmpty
                          ? Text(
                              "Select file",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiaryContainer),
                            )
                          : Text(
                              "File selected:  ${smrprovider.last.file.path.split('/').last}",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onTertiaryContainer),
                            ),
                      ElevatedButton(
                        onPressed: () async {
                          //retrievalQA = await loadFile();
                          print("___________${smrprovider.last.file}");
                        },
                        child: const Text(
                          'Không cần làm gì chỉ cần nhấp vào đây',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          getResponsive();
                        },
                        child: const Text(
                          'Không cần làm gì chỉ cần nhấp vào đây',
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.builder(
                controller: _listScrollController,
                itemCount: smrprovider.length, //chatList.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: ChatWidget(
                      msg: smrprovider[index].msg,
                      // chatList[index].msg,
                      chatIndex: smrprovider[index].chatIndex,
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
                        hintText: "What do you want to ask?",
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
            .watch(sMRProvider.notifier)
            .addUserMessage(msg: msg, chatid: chatid, file: File(file!.path!));
        textEditingController.clear();
        focusNode.unfocus();
      });

      OpenAI.apiKey = apiKey;
      await ref.watch(sMRProvider.notifier).sendMessageSMR(
          msg: msg,
          chosenModelId: "gpt-3.5-turbo",
          chatid: chatid,
          file: File(file!.path!));
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
