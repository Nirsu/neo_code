import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../env/env.dart';

class AiService {
  final Dio _dio;
  final String _model;

  AiService({required String apiKey, required String baseUrl, required String model})
      : _model = model,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 120),
          validateStatus: (status) => status != null && status < 500,
        ));

  Future<String> askZai(String prompt) async {
    return chatWithHistory(message: prompt, history: [], sharedContext: null);
  }

  Future<String> chatWithHistory({
    required String message,
    required List<Map<String, String>> history,
    String? sharedContext,
  }) async {
    try {
      final messages = <Map<String, String>>[];

      messages.add({
        'role': 'system',
        'content': 'Tu es l\'assistant de Neo Code. Utilise le contexte partagé fourni pour répondre avec précision.',
      });

      if (sharedContext != null && sharedContext.isNotEmpty) {
        messages.add({'role': 'system', 'content': 'Contexte supplémentaire:\n$sharedContext'});
      }

      messages.addAll(history);
      messages.add({'role': 'user', 'content': message});

      final response = await _dio.post<Map<String, dynamic>>(
        '/chat/completions',
        data: {
          'model': _model,
          'messages': messages,
        },
      );

      if (response.statusCode == 429) {
        return 'Limite de requêtes atteinte (rate limit). Réessaie dans quelques secondes.';
      }

      final data = response.data;
      if (data == null) return 'Erreur: réponse vide';

      final choices = data['choices'] as List<dynamic>?;
      if (choices != null && choices.isNotEmpty) {
        return choices[0]['message']['content'] as String? ?? '';
      }

      return 'Erreur: aucune réponse du modèle';
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      return 'Erreur API${status != null ? ' ($status)' : ''}: ${e.message ?? body ?? e.type.name}';
    } catch (e) {
      return 'Erreur: $e';
    }
  }

  Stream<String> chatWithHistoryStream({
    required String message,
    required List<Map<String, String>> history,
    String? sharedContext,
  }) async* {
    final messages = <Map<String, String>>[];

    messages.add({
      'role': 'system',
      'content': 'Tu es l\'assistant de Neo Code. Utilise le contexte partagé fourni pour répondre avec précision.',
    });

    if (sharedContext != null && sharedContext.isNotEmpty) {
      messages.add({'role': 'system', 'content': 'Contexte supplémentaire:\n$sharedContext'});
    }

    messages.addAll(history);
    messages.add({'role': 'user', 'content': message});

    final response = await _dio.post<ResponseBody>(
      '/chat/completions',
      data: {
        'model': _model,
        'messages': messages,
        'stream': true,
      },
      options: Options(responseType: ResponseType.stream),
    );

    final stream = response.data?.stream;
    if (stream == null) return;

    var buffer = '';
    await for (final chunk in stream) {
      buffer += String.fromCharCodes(chunk);
      final lines = buffer.split('\n');
      buffer = lines.removeLast();

      for (final line in lines) {
        final trimmed = line.trim();
        if (!trimmed.startsWith('data: ')) continue;
        final payload = trimmed.substring(6).trim();
        if (payload == '[DONE]') return;
        if (payload.isEmpty) continue;

        try {
          final json = _tryParseJson(payload);
          if (json == null) continue;
          final choices = json['choices'] as List<dynamic>?;
          if (choices == null || choices.isEmpty) continue;
          final delta = choices[0]['delta'] as Map<String, dynamic>?;
          final content = delta?['content'] as String?;
          if (content != null) yield content;
        } catch (_) {}
      }
    }
  }

  Map<String, dynamic>? _tryParseJson(String source) {
    try {
      final decoded = jsonDecode(source);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(
    apiKey: Env.zApiKey,
    baseUrl: 'https://api.z.ai/api/paas/v4',
    model: 'glm-5.1',
  );
});
