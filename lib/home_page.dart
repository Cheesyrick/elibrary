import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'book.dart';
import 'checkout_page.dart';
import 'book_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
        const SnackBar(content: Text('Keranjang kosong')),
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

  void _navigateToBookDetail(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailPage(book: book),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Library'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _goToCheckout,
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${cartItems.length}',
                      style: const TextStyle(
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
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Rekomendasi Hari Ini',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 265,
            child: recommendedBooks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recommendedBooks.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () =>
                            _navigateToBookDetail(recommendedBooks[index]),
                        child: Padding(
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
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(10)),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          recommendedBooks[index].cover_image,
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[300],
                                        child: Icon(Icons.book,
                                            size: 50, color: Colors.grey[600]),
                                      ),
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
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          recommendedBooks[index].author,
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600]),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rp ${recommendedBooks[index].price?.toStringAsFixed(0) ?? 'N/A'}',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        ElevatedButton(
                                          onPressed: () => _addToCart(
                                              recommendedBooks[index]),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            minimumSize:
                                                const Size(double.infinity, 40),
                                          ),
                                          child: const Text('Add to Cart',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
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
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: allBooks[index].cover_image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: Icon(Icons.book,
                              color: Colors.grey[600], size: 30),
                        ),
                      ),
                    ),
                    title: Text(
                      allBooks[index].title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(allBooks[index].author),
                        const SizedBox(height: 4),
                        Text(
                          'Rp ${allBooks[index].price?.toStringAsFixed(0) ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => _addToCart(allBooks[index]),
                      tooltip: 'Tambahkan ke keranjang',
                    ),
                    isThreeLine: true,
                    onTap: () => _navigateToBookDetail(allBooks[index]),
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
