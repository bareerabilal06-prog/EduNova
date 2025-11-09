import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/phrase.dart';
import '../../providers/phrase_provider.dart';
import 'dart:math' as math;

class PhraseTile extends StatefulWidget {
  final Phrase phrase;
  final bool isUrdu;
  final VoidCallback onTap;
  final List<Color> gradientColors;

  const PhraseTile({
    super.key,
    required this.phrase,
    required this.isUrdu,
    required this.onTap,
    required this.gradientColors,
  });

  @override
  State<PhraseTile> createState() => _PhraseTileState();
}

class _PhraseTileState extends State<PhraseTile>
    with SingleTickerProviderStateMixin {
  bool _hoveringCard = false;
  bool _hoveringIcon = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFavorite(Phrase phrase, PhraseProvider provider, bool currentlyFav) async {
    if (currentlyFav) {
      await _controller.reverse(from: 1.0);
    } else {
      await _controller.forward(from: 0.0);
    }

    await provider.toggleFavorite(phrase);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PhraseProvider>(
      builder: (context, provider, _) {
        final isFav = provider.isFavorite(widget.phrase.id!);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hoveringCard = true),
          onExit: (_) => setState(() => _hoveringCard = false),
          child: AnimatedScale(
            scale: _hoveringCard ? 1.03 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Main Card
                GestureDetector(
                  onTap: widget.onTap,
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0x76ADE3FF),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(77, 255, 255, 255),
                            shape: BoxShape.circle,
                          ),
                          child: Text(widget.phrase.emoji, style: const TextStyle(fontSize: 36)),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Text(
                            widget.isUrdu ? widget.phrase.urduText : widget.phrase.englishText,
                            textAlign: TextAlign.center,
                            textDirection: widget.isUrdu ? TextDirection.rtl : TextDirection.ltr,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: widget.isUrdu ? 14 : 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: widget.isUrdu ? 'NotoNastaliqUrdu' : 'Inter',
                              height: widget.isUrdu ? 1.8 : 1.4,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Favorite Icon (non-My Phrases)
                if (widget.phrase.categoryId != 7)
                  Align(
                    alignment: Alignment.topRight,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _hoveringIcon = true),
                      onExit: (_) => setState(() => _hoveringIcon = false),
                      child: AnimatedScale(
                        scale: _hoveringIcon ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _hoveringIcon ? Colors.black38 : Colors.black26,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _toggleFavorite(widget.phrase, provider, isFav),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  final angle = _controller.value * math.pi;
                                  final showFront = _controller.value < 0.5;
                                  final icon = showFront
                                      ? (isFav ? Icons.favorite : Icons.favorite_border)
                                      : (isFav ? Icons.favorite : Icons.favorite);
                                  final color = showFront
                                      ? (isFav ? Colors.redAccent : Colors.white)
                                      : (isFav ? Colors.redAccent : Colors.redAccent);

                                  return Transform(
                                    alignment: Alignment.center,
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(angle),
                                    child: Icon(icon, key: ValueKey(isFav), color: color, size: 20),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Delete Icon (My Phrases)
                if (widget.phrase.categoryId == 7)
                  Align(
                    alignment: Alignment.topRight,
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _hoveringIcon = true),
                      onExit: (_) => setState(() => _hoveringIcon = false),
                      child: AnimatedScale(
                        scale: _hoveringIcon ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _hoveringIcon ? Colors.black38 : Colors.black26,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Delete Phrase"),
                                  content: const Text("Are you sure you want to delete this phrase?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text("Cancel"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text("Delete", style: TextStyle(color: Colors.redAccent)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await provider.deletePhrase(widget.phrase.id!);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Phrase deleted successfully"), duration: Duration(seconds: 2)),
                                  );
                                }
                              }
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.delete, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
