import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiNotifier extends StateNotifier<String> {
  ApiNotifier() : super("");

  bool saveAPIKey(String apiKey) {
    state = apiKey;
    return true;
  }
}

final apiKeyProvider = StateNotifierProvider<ApiNotifier, String>((ref) {
  return ApiNotifier();
});
