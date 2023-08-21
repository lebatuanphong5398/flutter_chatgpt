import 'dart:io';

import 'package:collection/collection.dart';
import 'package:first_app/constants/api_consts.dart';
import 'package:first_app/providers/chatid_provider.dart';
import 'package:first_app/providers/summary_provider.dart';
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
  RetrievalQAChain? retrievalQA;
  Future filePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      file = result.files.first;
      ref.watch(sMRProvider.notifier).addfile(file: File(file!.path!));
    }
  }

  Future<void> loadFile() async {
    var loader = TextLoader(file!.path!);
    final documents = await loader.load();
    const textSplitter = RecursiveCharacterTextSplitter(
      chunkSize: 500,
      chunkOverlap: 0,
    );
    final texts = textSplitter.splitDocuments(documents);
    final textsWithSources = texts
        .mapIndexed(
          (final i, final d) => d.copyWith(
            metadata: {
              ...d.metadata,
              'source': '$i-pl',
            },
          ),
        )
        .toList(growable: false);
    final embeddings = OpenAIEmbeddings(apiKey: apiKey);
    final docSearch = await MemoryVectorStore.fromDocuments(
      documents: textsWithSources,
      embeddings: embeddings,
    );
    final llm = ChatOpenAI(
      apiKey: apiKey,
      model: 'gpt-3.5-turbo-0613',
      temperature: 0,
    );
    final qaChain = OpenAIQAWithSourcesChain(llm: llm);
    final docPrompt = PromptTemplate.fromTemplate(
      'Content: {page_content}\nSource: {source}',
    );
    final finalQAChain = StuffDocumentsChain(
      llmChain: qaChain,
      documentPrompt: docPrompt,
    );
    retrievalQA = RetrievalQAChain(
      retriever: docSearch.asRetriever(),
      combineDocumentsChain: finalQAChain,
    );
  }

  bool isTyping = false;
  late TextEditingController textEditingController;
  late ScrollController _listScrollController;
  late FocusNode focusNode;
  bool isloadfile = false;

  @override
  void initState() {
    setState(() {});
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
                          await filePicker();
                          setState(() {
                            isloadfile = true;
                          });
                          await loadFile();
                          setState(() {
                            isloadfile = false;
                          });
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
                      if (smrprovider.isEmpty)
                        Text(
                          "File selected: ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer),
                        )
                      else
                        Text(
                          "File selected:  ${smrprovider.last.file.path.split('/').last}",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onTertiaryContainer),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isloadfile)
            const CircularProgressIndicator()
          else
            Expanded(
              child: Column(
                children: [
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
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary),
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .background,
                                  ),
                              controller: textEditingController,
                              onSubmitted: (value) async {
                                await sendMessageFCT();
                              },
                              decoration: InputDecoration.collapsed(
                                hintText: "What do you want to ask?",
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
        ref.watch(sMRProvider.notifier).addUserMessage(
            msg: msg,
            chatid: ref.watch(chatidProvider),
            file: File(file!.path!));
        textEditingController.clear();
        focusNode.unfocus();
      });

      await ref.watch(sMRProvider.notifier).sendMessageSMR(
            msg: msg,
            chatid: ref.watch(chatidProvider),
            file: File(file!.path!),
            retrievalQA: retrievalQA!,
          );

      setState(() {});
    } catch (error) {
      print(error);
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
