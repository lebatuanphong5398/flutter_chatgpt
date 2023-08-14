import 'dart:convert';

import 'package:first_app/constants/api_consts.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  PlatformFile? file;
  dynamic retrievalQA;
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
      });
    } else {
      // User canceled the picker
    }
  }

  void loaderFile() async {
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
        print(textsWithSources);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void getChatResponse() async {
    try {
      embeddings = OpenAIEmbeddings(apiKey: apiKey);
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
        '''Hãy sử dụng nội dung của tôi đã cung cấp trong file text để trả lời các câu hỏi bằng tiếng Việt.\nLưu ý: Nếu không tìm thấy câu trả lời trong nội dung đã cung cấp, hãy thông báo "Thông tin không có trong tài liệu đã cung cung cấp ".
        Nếu câu hỏi là các câu tương tự như: 'Xin chào', 'Hello'... hãy phản hồi: 'Xin chào, hãy đặt các câu hỏi liên quan đến tài liệu đã cung cấp.'.
        .\ncontent: {page_content}\nSource: {source}
        ''',
      );
      final finalQAChain = StuffDocumentsChain(
        llmChain: qaChain,
        documentPrompt: docPrompt,
      );
      print('Hello_retrievalQA');

      final retrievalQA = RetrievalQAChain(
        retriever: docSearch.asRetriever(),
        combineDocumentsChain: finalQAChain,
      );

      final res = await retrievalQA("Bác Hồ là ai");
      if (res['statusCode'] == 429) {
        _responsedAnswer =
            'Bạn đã giữ quá nhiều yêu cầu(Tối Tối đa 3 yêu cầu/phút), hãy thử lại sau 20s.';
        print("__________$_responsedAnswer");
        //chatConversation.add({'Ai': _responsedAnswer.trim()});
        //isLoading = false;
      } else {
        setState(() {
          print(res.toString());
          _responsedAnswer = res['result'].toString();
          print("__________$_responsedAnswer");
          //chatConversation.add({'Ai': _responsedAnswer.trim()});
          //isLoading = false;
        });
      }
    } catch (err) {
      {
        if (err.toString().contains('statusCode: 429')) {
          setState(() {
            _responsedAnswer =
                'Tài khoản của bạn bị giới hạn 3 req/min, hãy nâng cấp hoặc thử lại sau 20s.';
            // chatConversation.add({'Ai': _responsedAnswer.trim()});
            // isLoading = false;
          });
        } else {
          setState(() {
            _responsedAnswer =
                'Xin chào, hãy đặt các câu hỏi liên quan đến tài liệu đã cung cấp. ${err.toString()}';
            // chatConversation.add({'Ai': _responsedAnswer.trim()});
            // isLoading = false;
          });
        }
      }
    }
    print("__________$_responsedAnswer");
  }

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

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  onPressed: () {
                    _filePicker();
                    loaderFile();
                  },
                  child: Text(
                    'Select File',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer),
                  ),
                ),
                SizedBox(height: 8),
                file == null
                    ? Text(
                        "No file selected",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer),
                      )
                    : Text(
                        "File selected: ${file!.name}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onTertiaryContainer),
                      ),
                ElevatedButton(
                  onPressed: () {
                    getChatResponse();
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
    );
  }
}




// final llm = ChatOpenAI(
//   apiKey: openaiApiKey,
//   model: 'gpt-3.5-turbo-0613',
//   temperature: 1,
// );
// final qaChain = OpenAIQAWithSourcesChain(llm: llm);
// final docPrompt = PromptTemplate.fromTemplate(
//   'Content: {page_content}\nSource: {source}',
// );
// final finalQAChain = StuffDocumentsChain(
//   llmChain: qaChain,
//   documentPrompt: docPrompt,
// );
// final retrievalQA = RetrievalQAChain(
//   retriever: docSearch.asRetriever(),
//   combineDocumentsChain: finalQAChain,
// );
// const query = 'What did President Biden say about Russia?';
// final res = await retrievalQA(query);
