import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dart_openai/dart_openai.dart';
import 'package:first_app/constants/api_consts.dart';
import 'package:first_app/models/models.dart';
import 'package:first_app/models/srm_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/services/api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_models.dart';

class ApiService {
  // Send Message using ChatGPT API
  static Future<ChatModel> sendMessageGPT(
      {required String message, required String modelId}) async {
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
      return ChatModel(
        msg: chatgpt.choices[0].message.content,
        chatIndex: 1,
      );
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
        body: json.encode({"prompt": message, "n": 2, "size": "1024x1024"}));
    Map jsonResponse = jsonDecode(response.body);
    return ChatModel(
      msg: jsonResponse["data"][0]["url"],
      chatIndex: 1,
    );
  }

  static Future<SmrModel> sendMessageSMR(
      {required String message, required File file}) async {
    try {
      OpenAIChatCompletionModel chatgpt = await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo",
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
            role: OpenAIChatMessageRole.user,
            content: message,
          )
        ],
      );
      print(chatgpt.choices[0].message.content);
      return SmrModel(
          msg: chatgpt.choices[0].message.content, chatIndex: 1, file: file);
    } catch (error) {
      rethrow;
    }
  }
}
