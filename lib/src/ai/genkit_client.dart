import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genkit/genkit.dart';
import 'package:genkit_openai/genkit_openai.dart';
import '../env/env.dart';

// Configurer le modèle Z.ai GLM 5.1 via l'adaptateur OpenAI
final zAiModelRef = openAI.model(
  'glm-5.1',
);

/// Provider du client Genkit
final genkitProvider = Provider<Genkit>((ref) {
  return Genkit(
    plugins: [
      openAI(
        apiKey: Env.zApiKey,
        baseUrl: 'https://api.z.ai/api/paas/v4/',
      ),
    ],
  );
});

/// Flow Genkit simple
final simpleChatFlowProvider = Provider<Flow<String, String, void, void>>((
  ref,
) {
  final ai = ref.watch(genkitProvider);

  // Flow Genkit (Dart 0.10.x attend fn et ActionFnArg)
  return ai.defineFlow<String, String, void, void>(
    name: 'zaiSimpleChat',
    fn: (String prompt, context) async {
      try {
        final response = await ai.generate(model: zAiModelRef, prompt: prompt);
        return response.text;
      } catch (e) {
        return "Erreur lors de la génération: $e";
      }
    },
  );
});

class AiService {
  final Flow<String, String, void, void> _chatFlow;

  AiService(this._chatFlow);

  /// Envoie un prompt simple via Genkit à Z.ai
  Future<String> askZai(String prompt) async {
    final res = await _chatFlow.run(prompt);
    return res.result;
  }
}

/// Provider pour manipuler facilement les requêtes
final aiServiceProvider = Provider<AiService>((ref) {
  final flow = ref.watch(simpleChatFlowProvider);
  return AiService(flow);
});
