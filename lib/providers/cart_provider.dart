import 'package:flutter/foundation.dart';
import '../book.dart';
import '../helpers/database_helper.dart';

class CartProvider with ChangeNotifier {
  List<Book> _items = [];
  final dbHelper = DatabaseHelper.instance;

  List<Book> get items => [..._items];

  Future<void> loadCart() async {
    _items = await dbHelper.getCartItems();
    notifyListeners();
  }

  Future<void> addItem(Book book) async {
    await dbHelper.insertBook(book); // Ensure book exists in DB
    await dbHelper.addToCart(book.id);
    _items.add(book);
    notifyListeners();
  }

  Future<void> removeItem(Book book) async {
    await dbHelper.removeFromCart(book.id);
    _items.remove(book);
    notifyListeners();
  }

  Future<void> clear() async {
    await dbHelper.clearCart();
    _items = [];
    notifyListeners();
  }
}
