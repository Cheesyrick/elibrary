import 'package:flutter/foundation.dart';
import 'dart:math';

class PriceProvider with ChangeNotifier {
  final Map<String, double> _prices = {};
  final random = Random();

  double getPriceForBook(String bookId) {
    if (!_prices.containsKey(bookId)) {
      double randomPrice = 50000 + random.nextDouble() * 50000;
      randomPrice = (randomPrice / 1000).round() * 1000;
      _prices[bookId] = randomPrice;
    }
    return _prices[bookId]!;
  }

  void clearPrices() {
    _prices.clear();
    notifyListeners();
  }
}
