import 'package:flutter/material.dart';
import '../../core/models/phrase.dart';

class PhraseTile extends StatelessWidget {
  final Phrase phrase;
  final bool isUrdu;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const PhraseTile({
    Key? key,
    required this.phrase,
    required this.isUrdu,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Text(phrase.emoji, style: const TextStyle(fontSize: 32)),
        title: Text(
          isUrdu ? phrase.urduText : phrase.englishText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          isUrdu ? phrase.englishText : phrase.urduText,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        trailing: IconButton(
          icon: Icon(
            phrase.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: phrase.isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: onFavoriteToggle,
        ),
        onTap: onTap,
      ),
    );
  }
}