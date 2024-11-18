import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../book.dart';
import '../models/user.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('books.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Create books table
    await db.execute('''
      CREATE TABLE books(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        subject TEXT NOT NULL,
        synopsis TEXT NOT NULL,
        cover_image TEXT NOT NULL,
        price REAL
      )
    ''');

    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        password TEXT,
        username TEXT
      )
    ''');

    // Create downloaded books table
    await db.execute('''
      CREATE TABLE downloaded_books(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books (id)
      )
    ''');

    // Create cart items table
    await db.execute('''
      CREATE TABLE cart_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        book_id TEXT NOT NULL,
        FOREIGN KEY (book_id) REFERENCES books (id)
      )
    ''');
  }

  // Add these methods for user management
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUser(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  // Books operations
  Future<void> insertBook(Book book) async {
    final db = await database;
    await db.insert(
      'books',
      {
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'subject': book.subject,
        'synopsis': book.synopsis,
        'cover_image': book.cover_image,
        'price': book.price,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Book>> getAllBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('books');
    return List.generate(maps.length, (i) => Book.fromJson(maps[i]));
  }

  // Cart operations
  Future<void> addToCart(String bookId) async {
    final db = await database;
    await db.insert(
      'cart_items',
      {'book_id': bookId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromCart(String bookId) async {
    final db = await database;
    await db.delete(
      'cart_items',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  Future<List<Book>> getCartItems() async {
    final db = await database;
    final List<Map<String, dynamic>> cartMaps = await db.rawQuery('''
      SELECT books.* FROM books
      INNER JOIN cart_items ON books.id = cart_items.book_id
    ''');
    return List.generate(cartMaps.length, (i) => Book.fromJson(cartMaps[i]));
  }

  // Downloaded books operations
  Future<void> addToDownloaded(String bookId) async {
    final db = await database;
    await db.insert(
      'downloaded_books',
      {'book_id': bookId},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFromDownloaded(String bookId) async {
    final db = await database;
    await db.delete(
      'downloaded_books',
      where: 'book_id = ?',
      whereArgs: [bookId],
    );
  }

  Future<List<Book>> getDownloadedBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> downloadedMaps = await db.rawQuery('''
      SELECT books.* FROM books
      INNER JOIN downloaded_books ON books.id = downloaded_books.book_id
    ''');
    return List.generate(
        downloadedMaps.length, (i) => Book.fromJson(downloadedMaps[i]));
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'books.db');
    await databaseFactory.deleteDatabase(path);
    _database = null;
  }
}
