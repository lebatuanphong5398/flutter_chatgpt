import 'dart:convert';
import 'dart:io';
import 'package:dart_openai/dart_openai.dart';
import 'package:first_app/constants/api_consts.dart';
import 'package:first_app/models/srm_model.dart';
import 'package:http/http.dart' as http;
import 'package:langchain/langchain.dart';
import '../models/chat_models.dart';

class ApiService {
  //Send Message using ChatGPT API
  static Future<String> sendMessageGPT({
    required String message,
    required String modelId,
  }) async {
    try {
      OpenAIChatCompletionModel chatgpt = await OpenAI.instance.chat.create(
        model: modelId,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: message,
          )
        ],
      );
      print(chatgpt.choices[0].message.content);
      return chatgpt.choices[0].message.content;
    } catch (error) {
      rethrow;
    }
  }

  static Future<ChatModel> generationsimages({
    required String message,
  }) async {
    final url = Uri.https('api.openai.com', 'v1/images/generations');
    var response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          "Content-Type": "application/json"
        },
        body: json.encode({"prompt": message, "n": 1, "size": "1024x1024"}));
    Map jsonResponse = jsonDecode(response.body);
    print("________________${response.body}");
    return ChatModel(
      msg: jsonResponse["data"][0]["url"],
      chatIndex: 1,
    );
  }

  static Future<SmrModel> sendMessageSMR(
      {required String message,
      required File file,
      required RetrievalQAChain retrievalQA}) async {
    try {
      final res = await retrievalQA(message);
      print("______________________$res");
      print("---------------${res['statusCode']}");
      print(res["result"].toString());

      return SmrModel(msg: res["result"].toString(), chatIndex: 1, file: file);
    } catch (error) {
      rethrow;
    }
  }
}
