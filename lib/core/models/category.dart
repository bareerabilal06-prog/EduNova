class Category {
  final int id;
  final String name;
  final String urduName;
  final String icon;
  final int phraseCount;

  Category({
    required this.id,
    required this.name,
    required this.urduName,
    required this.icon,
    required this.phraseCount,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int,
      name: map['name'] as String,
      urduName: map['urdu_name'] as String? ?? '',
      icon: map['icon'] as String,
      phraseCount: map['phraseCount'] is int
          ? map['phraseCount'] as int
          : int.tryParse(map['phraseCount'].toString()) ?? 0,
    );
  }
}
