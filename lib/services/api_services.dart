import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dart_openai/dart_openai.dart';
import 'package:first_app/constants/api_consts.dart';
import 'package:first_app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:first_app/services/api_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_models.dart';

class ApiService {
  static Future<List<ModelsModel>> getModels() async {
    try {
      var response = await http.get(
        Uri.parse("$Base_url/models"),
        headers: {'Authorization': 'Bearer $apiKey'},
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      // print("jsonResponse $jsonResponse");
      List temp = [];
      for (var value in jsonResponse["data"]) {
        temp.add(value);
        // log("temp ${value["id"]}");
      }
      return ModelsModel.modelsFromSnapshot(temp);
    } catch (error) {
      //log("error $error");
      rethrow;
    }
  }

  // Send Message using ChatGPT API
  static Future<ChatModel> sendMessageGPT(
      {required String message, required String modelId}) async {
    try {
      OpenAIChatCompletionModel chatgpt = await OpenAI.instance.chat.create(
        model: modelId,
        messages: [
          OpenAIChatCompletionChoiceMessageModel(
              role: OpenAIChatMessageRole.user, content: message)
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

  // Send Message fct
  static Future<List<ChatModel>> sendMessage(
      {required String message, required String modelId}) async {
    try {
      //log("modelId $modelId");
      var response = await http.post(
        Uri.parse("$Base_url/completions"),
        headers: {
          'Authorization': 'Bearer $apiKey',
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          {
            "model": modelId,
            "prompt": message,
            "max_tokens": 300,
          },
        ),
      );

      Map jsonResponse = jsonDecode(response.body);

      if (jsonResponse['error'] != null) {
        // print("jsonResponse['error'] ${jsonResponse['error']["message"]}");
        throw HttpException(jsonResponse['error']["message"]);
      }
      List<ChatModel> chatList = [];
      if (jsonResponse["choices"].length > 0) {
        // log("jsonResponse[choices]text ${jsonResponse["choices"][0]["text"]}");
        chatList = List.generate(
          jsonResponse["choices"].length,
          (index) => ChatModel(
            msg: jsonResponse["choices"][index]["text"],
            chatIndex: 1,
          ),
        );
      }
      return chatList;
    } catch (error) {
      //log("error $error");
      rethrow;
    }
  }
}
