import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/category.dart';
import '../models/phrase.dart';
import '../models/profile.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'edunova.db');

    return await openDatabase(
      path,
      version: 2, // 🔺 bumped version for urdu_name column
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create profile table
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT NOT NULL,
        age INTEGER NOT NULL,
        email TEXT
      )
    ''');

    // Create categories table (added urdu_name)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        urdu_name TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

    // Create phrases table
    await db.execute('''
      CREATE TABLE phrases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        english_text TEXT NOT NULL,
        urdu_text TEXT NOT NULL,
        emoji TEXT NOT NULL,
        is_favorite INTEGER DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await _seedData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // 🔹 Add urdu_name column for users upgrading old DB
      await db.execute('ALTER TABLE categories ADD COLUMN urdu_name TEXT');
    }
  }

  Future<void> _seedData(Database db) async {
    // Insert categories with Urdu names
    List<Map<String, dynamic>> categories = [
      {'name': 'Questions', 'urdu_name': 'سوالات', 'icon': '❓'},
      {'name': 'Answers', 'urdu_name': 'جوابات', 'icon': '✅'},
      {'name': 'Emotions', 'urdu_name': 'جذبات', 'icon': '😊'},
      {'name': 'Needs', 'urdu_name': 'ضرورتیں', 'icon': '🧩'},
      {'name': 'Actions', 'urdu_name': 'اعمال', 'icon': '⚡'},
      {'name': 'Favorites', 'urdu_name': 'پسندیدہ', 'icon': '⭐'},
    ];

    for (var cat in categories) {
      await db.insert('categories', cat);
    }

    // Insert phrases
    List<Map<String, dynamic>> phrases = [
      // 📋 Questions
      {'category_id': 1, 'english_text': 'What page are we on?', 'urdu_text': 'ہم کس صفحے پر ہیں؟', 'emoji': '📄'},
      {'category_id': 1, 'english_text': 'Can you repeat that?', 'urdu_text': 'کیا آپ اسے دہرا سکتے ہیں؟', 'emoji': '🔁'},
      {'category_id': 1, 'english_text': 'How do you spell this?', 'urdu_text': 'اس کی ہجے کیسے کریں؟', 'emoji': '🔤'},
      {'category_id': 1, 'english_text': 'What does this mean?', 'urdu_text': 'اس کا کیا مطلب ہے؟', 'emoji': '❓'},
      {'category_id': 1, 'english_text': 'Can I ask a question?', 'urdu_text': 'کیا میں ایک سوال پوچھ سکتا ہوں؟', 'emoji': '💬'},
      {'category_id': 1, 'english_text': 'Which chapter is this?', 'urdu_text': 'یہ کون سا باب ہے؟', 'emoji': '📖'},
      {'category_id': 1, 'english_text': 'Is this correct?', 'urdu_text': 'کیا یہ صحیح ہے؟', 'emoji': '✅'},
      {'category_id': 1, 'english_text': 'What\'s the homework?', 'urdu_text': 'ہوم ورک کیا ہے؟', 'emoji': '🏠'},
      {'category_id': 1, 'english_text': 'Can you explain again?', 'urdu_text': 'کیا آپ دوبارہ وضاحت کر سکتے ہیں؟', 'emoji': '🔁'},
      {'category_id': 1, 'english_text': 'What time is it?', 'urdu_text': 'کتنا بجا ہے؟', 'emoji': '⏰'},

      // 💬 Answers
      {'category_id': 2, 'english_text': 'Yes', 'urdu_text': 'جی ہاں', 'emoji': '✅'},
      {'category_id': 2, 'english_text': 'No', 'urdu_text': 'نہیں', 'emoji': '❌'},
      {'category_id': 2, 'english_text': 'I understand', 'urdu_text': 'میں سمجھ گیا', 'emoji': '👍'},
      {'category_id': 2, 'english_text': 'I don\'t understand', 'urdu_text': 'میں نہیں سمجھا', 'emoji': '👎'},
      {'category_id': 2, 'english_text': 'Maybe', 'urdu_text': 'شاید', 'emoji': '🤔'},
      {'category_id': 2, 'english_text': 'I think so', 'urdu_text': 'مجھے ایسا لگتا ہے', 'emoji': '💭'},
      {'category_id': 2, 'english_text': 'I\'m not sure', 'urdu_text': 'مجھے یقین نہیں ہے', 'emoji': '❓'},
      {'category_id': 2, 'english_text': 'That\'s correct', 'urdu_text': 'یہ صحیح ہے', 'emoji': '✅'},
      {'category_id': 2, 'english_text': 'That\'s wrong', 'urdu_text': 'یہ غلط ہے', 'emoji': '❌'},
      {'category_id': 2, 'english_text': 'I agree', 'urdu_text': 'میں متفق ہوں', 'emoji': '🤝'},

      // 😊 Emotions
      {'category_id': 3, 'english_text': 'Happy', 'urdu_text': 'خوش', 'emoji': '😊'},
      {'category_id': 3, 'english_text': 'Sad', 'urdu_text': 'اداس', 'emoji': '😢'},
      {'category_id': 3, 'english_text': 'Excited', 'urdu_text': 'پرجوش', 'emoji': '🤩'},
      {'category_id': 3, 'english_text': 'Confused', 'urdu_text': 'الجھن میں', 'emoji': '😕'},
      {'category_id': 3, 'english_text': 'Frustrated', 'urdu_text': 'مایوس', 'emoji': '😤'},
      {'category_id': 3, 'english_text': 'Tired', 'urdu_text': 'تھکا ہوا', 'emoji': '😴'},
      {'category_id': 3, 'english_text': 'Bored', 'urdu_text': 'بیزار', 'emoji': '🥱'},
      {'category_id': 3, 'english_text': 'Surprised', 'urdu_text': 'حیران', 'emoji': '😲'},
      {'category_id': 3, 'english_text': 'Proud', 'urdu_text': 'فخر', 'emoji': '🏆'},
      {'category_id': 3, 'english_text': 'Curious', 'urdu_text': 'متجسس', 'emoji': '🤔'},

      // 🧩 Needs
      {'category_id': 4, 'english_text': 'I need water', 'urdu_text': 'مجھے پانی چاہیے', 'emoji': '💧'},
      {'category_id': 4, 'english_text': 'Bathroom break', 'urdu_text': 'باتھ روم بریک', 'emoji': '🚽'},
      {'category_id': 4, 'english_text': 'I need help', 'urdu_text': 'مجھے مدد چاہیے', 'emoji': '🆘'},
      {'category_id': 4, 'english_text': 'I need a break', 'urdu_text': 'مجھے آرام چاہیے', 'emoji': '⏸️'},
      {'category_id': 4, 'english_text': 'I need a pencil', 'urdu_text': 'مجھے پنسل چاہیے', 'emoji': '✏️'},
      {'category_id': 4, 'english_text': 'I need paper', 'urdu_text': 'مجھے کاغذ چاہیے', 'emoji': '📄'},
      {'category_id': 4, 'english_text': 'I\'m hungry', 'urdu_text': 'مجھے بھوک لگی ہے', 'emoji': '🍎'},
      {'category_id': 4, 'english_text': 'I\'m thirsty', 'urdu_text': 'مجھے پیاس لگی ہے', 'emoji': '💧'},
      {'category_id': 4, 'english_text': 'I feel sick', 'urdu_text': 'میں بیمار محسوس کر رہا ہوں', 'emoji': '🤒'},
      {'category_id': 4, 'english_text': 'I need medicine', 'urdu_text': 'مجھے دوا چاہیے', 'emoji': '💊'},

      // ⚡ Actions
      {'category_id': 5, 'english_text': 'Let\'s play', 'urdu_text': 'چلیں کھیلیں', 'emoji': '🎮'},
      {'category_id': 5, 'english_text': 'Let\'s read', 'urdu_text': 'چلیں پڑھیں', 'emoji': '📖'},
      {'category_id': 5, 'english_text': 'Let\'s write', 'urdu_text': 'چلیں لکھیں', 'emoji': '✍️'},
      {'category_id': 5, 'english_text': 'Let\'s draw', 'urdu_text': 'چلیں بنائیں', 'emoji': '🎨'},
      {'category_id': 5, 'english_text': 'Let\'s listen', 'urdu_text': 'چلیں سنیں', 'emoji': '👂'},
      {'category_id': 5, 'english_text': 'Let\'s learn', 'urdu_text': 'چلیں سیکھیں', 'emoji': '🧠'},
      {'category_id': 5, 'english_text': 'Let\'s practice', 'urdu_text': 'چلیں مشق کریں', 'emoji': '🔁'},
      {'category_id': 5, 'english_text': 'Let\'s share', 'urdu_text': 'چلیں بانٹیں', 'emoji': '🤲'},
      {'category_id': 5, 'english_text': 'Let\'s create', 'urdu_text': 'چلیں تخلیق کریں', 'emoji': '🎭'},
      {'category_id': 5, 'english_text': 'Let\'s explore', 'urdu_text': 'چلیں دریافت کریں', 'emoji': '🔍'},

      // ⭐ Favorites
      {'category_id': 6, 'english_text': 'Thank you', 'urdu_text': 'شکریہ', 'emoji': '🙏'},
      {'category_id': 6, 'english_text': 'Please', 'urdu_text': 'براہ کرم', 'emoji': '✨'},
      {'category_id': 6, 'english_text': 'Good job!', 'urdu_text': 'بہت اچھے!', 'emoji': '👏'},
      {'category_id': 6, 'english_text': 'I love this', 'urdu_text': 'مجھے یہ پسند ہے', 'emoji': '❤️'},
      {'category_id': 6, 'english_text': 'Awesome!', 'urdu_text': 'زبردست!', 'emoji': '🔥'},
      {'category_id': 6, 'english_text': 'Well done!', 'urdu_text': 'بہت خوب!', 'emoji': '🎯'},
      {'category_id': 6, 'english_text': 'Excellent!', 'urdu_text': 'شاندار!', 'emoji': '🌟'},
      {'category_id': 6, 'english_text': 'Perfect!', 'urdu_text': 'بہترین!', 'emoji': '💯'},
      {'category_id': 6, 'english_text': 'Amazing!', 'urdu_text': 'حیرت انگیز!', 'emoji': '🤩'},
      {'category_id': 6, 'english_text': 'Wonderful!', 'urdu_text': 'عمدہ!', 'emoji': '🌈'},
    ];

    for (var phrase in phrases) {
      await db.insert('phrases', phrase);
    }
  }

  // ---------------- Profile CRUD ----------------

  Future<int> insertProfile(Profile profile) async {
    final db = await database;
    await db.delete('profile');
    return await db.insert('profile', profile.toMap());
  }

  Future<Profile?> getProfile() async {
    final db = await database;
    final result = await db.query('profile', limit: 1);
    if (result.isEmpty) return null;
    return Profile.fromMap(result.first);
  }

  Future<int> updateProfile(Profile profile) async {
    final db = await database;
    if (profile.id == null) {
      await db.delete('profile');
      return await db.insert('profile', profile.toMap());
    }
    return await db.update(
      'profile',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  // ---------------- Category CRUD ----------------

  Future<List<Category>> getCategories() async {
    final db = await database;

    final result = await db.rawQuery('''
      SELECT c.id, c.name, c.urdu_name, c.icon, COUNT(p.id) AS phraseCount
      FROM categories c
      LEFT JOIN phrases p ON c.id = p.category_id
      GROUP BY c.id
    ''');

    return result.map((row) {
      return Category(
        id: row['id'] as int,
        name: row['name'] as String,
        urduName: row['urdu_name'] as String? ?? '',
        icon: row['icon'] as String,
        phraseCount: row['phraseCount'] is int
            ? row['phraseCount'] as int
            : int.tryParse(row['phraseCount'].toString()) ?? 0,
      );
    }).toList();
  }

  // ---------------- Phrase CRUD ----------------

  Future<List<Phrase>> getPhrasesByCategory(int categoryId) async {
    final db = await database;
    final maps = await db.query(
      'phrases',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return maps.map((e) => Phrase.fromMap(e)).toList();
  }

  Future<List<Phrase>> getFavoritePhrases() async {
    final db = await database;
    final maps = await db.query(
      'phrases',
      where: 'is_favorite = ?',
      whereArgs: [1],
    );
    return maps.map((e) => Phrase.fromMap(e)).toList();
  }

  Future<int> toggleFavorite(int phraseId, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'phrases',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [phraseId],
    );
  }

  Future<int> getPhraseCountByCategory(int categoryId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM phrases WHERE category_id = ?',
      [categoryId],
    );
    if (result.isNotEmpty) {
      final count = result.first['count'];
      if (count is int) return count;
      if (count is int?) return count ?? 0;
      return int.tryParse(count.toString()) ?? 0;
    }
    return 0;
  }

  // ---------------- Utility ----------------

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('profile');
    await db.delete('phrases');
    await db.delete('categories');
    await _seedData(db);
  }
}
