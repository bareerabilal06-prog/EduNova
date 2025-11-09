import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ai_provider_online.dart';
import '../../providers/phrase_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../core/models/phrase.dart';

class AISentenceBuilderOnlineScreen extends StatefulWidget {
  const AISentenceBuilderOnlineScreen({super.key});

  @override
  State<AISentenceBuilderOnlineScreen> createState() =>
      _AISentenceBuilderOnlineScreenState();
}

class _AISentenceBuilderOnlineScreenState
    extends State<AISentenceBuilderOnlineScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    context.read<AIProviderOnline>().initSuggestions();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final ai = context.read<AIProviderOnline>();
    ai.builtSentence = _controller.text.trim();
    ai.getAISuggestions(ai.builtSentence).then((suggestions) {
      ai.updateSuggestions(suggestions);
    });
  }

  // void _showError(String message) {
  //   if (!mounted) return;
  //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  // }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityProvider>().isOnline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Sentence Builder (Online)'),
        backgroundColor: const Color(0xFF1E88E5),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear sentence',
            onPressed: () {
              _controller.clear();
              context.read<AIProviderOnline>().clearSentence();
            },
          ),
        ],
      ),
      body: !isOnline
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            '⚠️ You are offline.\nPlease connect to the internet to use Online AI.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      )
          : Consumer<AIProviderOnline>(
        builder: (context, aiProvider, _) {
          final isRTL = Directionality.of(context) == TextDirection.rtl;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 🔹 Input Field
                TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  textDirection:
                  isRTL ? TextDirection.rtl : TextDirection.ltr,
                  decoration: InputDecoration(
                    hintText: 'Type your sentence...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: aiProvider.builtSentence.isEmpty
                          ? null
                          : () {
                        context
                            .read<PhraseProvider>()
                            .speakPhrase(
                          Phrase(
                            categoryId: 0,
                            englishText:
                            aiProvider.builtSentence,
                            urduText: aiProvider.builtSentence,
                            emoji: '🗣️',
                          ),
                          false,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 🔹 AI Suggestions Section
                if (aiProvider.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (aiProvider.currentSuggestions.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'No AI suggestions. Start typing to get help!',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children:
                        aiProvider.currentSuggestions.map((word) {
                          return ActionChip(
                            label: Text(word),
                            onPressed: () {
                              final text = _controller.text.trim();
                              final newText =
                              text.isEmpty ? word : '$text $word';
                              _controller.text = newText;
                              _controller.selection =
                                  TextSelection.fromPosition(TextPosition(
                                      offset: newText.length));
                              _onTextChanged();
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
