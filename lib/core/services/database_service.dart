import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/category.dart';
import '../models/phrase.dart';
import '../models/profile.dart';
import 'package:path_provider/path_provider.dart' as path_provider;


class DatabaseService {
  static Database? _database;

  DatabaseService() {
    // ✅ Initialize SQLite for desktop if needed
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'edunova.db');

    // Close existing DB
    if (_database != null) {
      await _database!.close();
      _database = null;
    }

    // Delete the file if it exists
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
      //print('Database deleted at $path');
    }

    // Recreate the DB by calling getter
    await database;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Future<Database> _initDatabase() async {
  //   final dbPath = await getDatabasesPath();
  //   final path = join(dbPath, 'edunova.db');
  //
  //   return await databaseFactory.openDatabase(
  //     path,
  //     options: OpenDatabaseOptions(
  //       version: 2,
  //       onCreate: _onCreate,
  //       onUpgrade: _onUpgrade,
  //     ),
  //   );
  // }

  Future<Database> _initDatabase() async {
    String dbDirectory;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // ✅ Use AppData (writable & persistent in release builds)
      final dir = await path_provider.getApplicationSupportDirectory();
      dbDirectory = dir.path;
    } else {
      // ✅ Mobile platforms handle this fine
      dbDirectory = await getDatabasesPath();
    }

    final path = join(dbDirectory, 'edunova.db');

    //print('📁 Using database at: $path'); // (optional for testing)

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }


  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE profile (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT NOT NULL,
        age INTEGER NOT NULL,
        email TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        urdu_name TEXT NOT NULL,
        icon TEXT NOT NULL
      )
    ''');

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
      await db.execute('ALTER TABLE categories ADD COLUMN urdu_name TEXT');
    }
  }

  Future<void> _seedData(Database db) async {
    // ✅ Categories
    final categories = [
      {'name': 'Questions', 'urdu_name': 'سوالات', 'icon': '❓'},
      {'name': 'Answers', 'urdu_name': 'جوابات', 'icon': '✅'},
      {'name': 'Emotions', 'urdu_name': 'جذبات', 'icon': '😊'},
      {'name': 'Needs', 'urdu_name': 'ضرورتیں', 'icon': '🧩'},
      {'name': 'Actions', 'urdu_name': 'اعمال', 'icon': '⚡'},
      {'name': 'Favorites', 'urdu_name': 'پسندیدہ', 'icon': '⭐'}, // No seeded phrases
      {'name': 'My Phrases', 'urdu_name': 'میری فقرے', 'icon': '📝'}, // User category
    ];

    for (var cat in categories) {
      await db.insert('categories', cat);
    }

    // ✅ Phrases (skip Favorites 6 & My Phrases 7)
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
        phraseCount: int.tryParse(row['phraseCount'].toString()) ?? 0,
      );
    }).toList();
  }

  // ---------------- Phrase CRUD ----------------

  /// Insert a new phrase into the DB and return the inserted row id.
  Future<int> insertPhrase(Phrase phrase) async {
    final db = await database;

    // Prepare a map matching your table columns
    final Map<String, dynamic> row = {
      'category_id': phrase.categoryId,
      'english_text': phrase.englishText,
      'urdu_text': phrase.urduText ?? '',
      'emoji': phrase.emoji ?? '📝',
      'is_favorite': (phrase.isFavorite ?? false) ? 1 : 0,
    };

    return await db.insert(
      'phrases',
      row,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deletePhrase(int id) async {
    final db = await database;
    await db.delete('phrases', where: 'id = ?', whereArgs: [id]);
  }


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
