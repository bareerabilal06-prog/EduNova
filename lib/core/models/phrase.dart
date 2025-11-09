class Phrase {
  final int? id;
  final int categoryId;
  final String englishText;
  final String urduText;
  final String emoji;
  final bool isFavorite;

  Phrase({
    this.id,
    required this.categoryId,
    required this.englishText,
    required this.urduText,
    required this.emoji,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_id': categoryId,
      'english_text': englishText,
      'urdu_text': urduText,
      'emoji': emoji,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory Phrase.fromMap(Map<String, dynamic> map) {
    return Phrase(
      id: map['id'],
      categoryId: map['category_id'],
      englishText: map['english_text'],
      urduText: map['urdu_text'],
      emoji: map['emoji'],
      isFavorite: map['is_favorite'] == 1,
    );
  }

  Phrase copyWith({bool? isFavorite}) {
    return Phrase(
      id: id,
      categoryId: categoryId,
      englishText: englishText,
      urduText: urduText,
      emoji: emoji,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}