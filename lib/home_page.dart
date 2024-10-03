import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:math';
import 'book.dart';
import 'checkout_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Book> allBooks = [];
  List<Book> recommendedBooks = [];
  List<Book> cartItems = [];

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final String response = await rootBundle.loadString('assets/books.json');
    final List<dynamic> data = await json.decode(response);
    final random = Random();
    setState(() {
      allBooks = data.map((bookData) {
        double randomPrice = 50000 + random.nextDouble() * 50000;
        randomPrice = (randomPrice / 1000).round() * 1000;
        return Book.fromJson({...bookData, 'price': randomPrice});
      }).toList();
      _getDailyRecommendations();
    });
  }

  void _getDailyRecommendations() {
    final DateTime now = DateTime.now();
    final int seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);

    final shuffledBooks = List<Book>.from(allBooks)..shuffle(random);
    recommendedBooks = shuffledBooks.take(3).toList();
  }

  void _addToCart(Book book) {
    setState(() {
      cartItems.add(book);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book.title} ditambahkan ke keranjang')),
    );
  }

  void _goToCheckout() {
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Keranjang kosong')),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(cartItems: cartItems),
        ),
      ).then((paymentCompleted) {
        if (paymentCompleted == true) {
          setState(() {
            cartItems.clear();
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rekomendasi Buku Hari Ini'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: _goToCheckout,
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartItems.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Rekomendasi Hari Ini',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 200,
            child: recommendedBooks.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendedBooks.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 160,
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.book,
                                        size: 50, color: Colors.grey[600]),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recommendedBooks[index].title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        recommendedBooks[index].author,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Semua Buku',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allBooks.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child:
                          Icon(Icons.book, color: Colors.grey[600], size: 30),
                    ),
                    title: Text(
                      allBooks[index].title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(allBooks[index].author),
                        SizedBox(height: 4),
                        Text(
                          'Rp ${allBooks[index].price?.toStringAsFixed(0) ?? 'N/A'}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.add_shopping_cart),
                      onPressed: () => _addToCart(allBooks[index]),
                      tooltip: 'Tambahkan ke keranjang',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
