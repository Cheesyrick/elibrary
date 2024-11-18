import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'book.dart';
import 'checkout_page.dart';
import 'book_detail_page.dart';
import 'downloaded_books_page.dart';
import 'package:provider/provider.dart';
import 'providers/cart_provider.dart';
import 'helpers/database_helper.dart';
import 'providers/price_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Book> allBooks = [];
  List<Book> recommendedBooks = [];
  List<Book> downloadedBooks = [];
  bool isOnlineMode = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loadBooks();
  }

  Future<void> _loadBooks() async {
    try {
      final String response = await rootBundle.loadString('assets/books.json');
      final List<dynamic> data = await json.decode(response);

      if (!mounted) return;

      final priceProvider = Provider.of<PriceProvider>(context, listen: false);

      List<Book> jsonBooks = data.map((bookData) {
        var book = Book.fromJson(bookData);
        book.price = priceProvider.getPriceForBook(book.id);
        return book;
      }).toList();

      // Store books in database
      for (var book in jsonBooks) {
        await DatabaseHelper.instance.insertBook(book);
      }

      if (!mounted) return;

      setState(() {
        allBooks = jsonBooks;
        _getDailyRecommendations();
      });

      await _loadDownloadedBooks();
    } catch (e) {
      if (!mounted) return;

      print('Error loading books: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading books: $e')),
      );
    }
  }

  Future<void> _loadDownloadedBooks() async {
    final books = await DatabaseHelper.instance.getDownloadedBooks();
    setState(() {
      downloadedBooks = books;
    });
  }

  void _getDailyRecommendations() {
    final DateTime now = DateTime.now();
    final int seed = now.year * 10000 + now.month * 100 + now.day;
    final random = Random(seed);

    if (allBooks.isEmpty) {
      recommendedBooks = [];
      return;
    }
    final shuffledBooks = List<Book>.from(allBooks)..shuffle(random);
    recommendedBooks = shuffledBooks.take(min(3, allBooks.length)).toList();
  }

  void _toggleOnlineMode(bool value) {
    setState(() {
      isOnlineMode = value;
    });
    if (!value) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DownloadedBooksPage(
            downloadedBooks: downloadedBooks,
            onDeleteBook: (Book book) {
              setState(() {
                downloadedBooks.remove(book);
              });
            },
            isOnline: isOnlineMode,
            onToggleOnline: (bool newValue) {
              setState(() {
                isOnlineMode = newValue;
              });
            },
          ),
        ),
      );
    }
  }

  Future<void> _downloadBook(Book book) async {
    if (!downloadedBooks.contains(book)) {
      await DatabaseHelper.instance.addToDownloaded(book.id);
      setState(() {
        downloadedBooks.add(book);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book.title} berhasil diunduh')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book.title} sudah diunduh sebelumnya')),
      );
    }
  }

  void _addToCart(Book book) {
    Provider.of<CartProvider>(context, listen: false).addItem(book);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${book.title} ditambahkan ke keranjang')),
    );
  }

  void _goToCheckout() {
    final cartItems = Provider.of<CartProvider>(context, listen: false).items;
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
          Provider.of<CartProvider>(context, listen: false).clear();
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
    final cartItems = Provider.of<CartProvider>(context).items;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        title: const Text(
          'E-library',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Switch(
            value: isOnlineMode,
            onChanged: _toggleOnlineMode,
            activeColor: Colors.white,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 28),
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
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 8),
        ],
      ),
      body: isOnlineMode
          ? _buildOnlineContent()
          : Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text('Lihat Buku yang Diunduh'),
                onPressed: () => _toggleOnlineMode(false),
              ),
            ),
    );
  }

  Widget _buildOnlineContent() {
    return Container(
      color: Colors.grey[100],
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekomendasi Hari Ini',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Temukan buku favorit Anda',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 350,
              child: recommendedBooks.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada rekomendasi',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedBooks.length,
                      itemBuilder: (context, index) {
                        final book = recommendedBooks[index];
                        final bool isDownloaded =
                            downloadedBooks.contains(book);
                        return GestureDetector(
                          onTap: () => _navigateToBookDetail(book),
                          child: Container(
                            width: 200,
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(15),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: book.cover_image,
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Container(
                                        color: Colors.grey[200],
                                        child: Icon(Icons.book,
                                            color: Colors.grey[600], size: 50),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          book.title,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          book.author,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Rp ${book.price?.toStringAsFixed(0) ?? 'N/A'}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.add_shopping_cart,
                                                    color: Colors.blue,
                                                  ),
                                                  onPressed: () =>
                                                      _addToCart(book),
                                                  tooltip:
                                                      'Tambahkan ke keranjang',
                                                ),
                                                if (!isDownloaded)
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.download,
                                                      color: Colors.blue,
                                                    ),
                                                    onPressed: () =>
                                                        _downloadBook(book),
                                                    tooltip: 'Unduh buku',
                                                  )
                                                else
                                                  Icon(
                                                    Icons.check_circle,
                                                    color: Colors.green,
                                                  ),
                                              ],
                                            ),
                                          ],
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
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: allBooks.length,
              itemBuilder: (context, index) {
                final book = allBooks[index];
                final bool isDownloaded = downloadedBooks.contains(book);
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () => _navigateToBookDetail(book),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: book.cover_image,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey[200],
                                child: Icon(Icons.book,
                                    color: Colors.grey[600], size: 40),
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  book.author,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Rp ${book.price?.toStringAsFixed(0) ?? 'N/A'}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.add_shopping_cart,
                                    color: Colors.blue),
                                onPressed: () => _addToCart(book),
                                tooltip: 'Tambahkan ke keranjang',
                              ),
                              if (!isDownloaded)
                                IconButton(
                                  icon:
                                      Icon(Icons.download, color: Colors.blue),
                                  onPressed: () => _downloadBook(book),
                                  tooltip: 'Unduh buku',
                                )
                              else
                                Icon(Icons.check_circle, color: Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
