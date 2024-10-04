import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'book.dart';
import 'checkout_page.dart';
import 'book_detail_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'downloaded_books_page.dart'; // Tambahkan import ini

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Book> allBooks = [];
  List<Book> recommendedBooks = [];
  List<Book> cartItems = [];
  List<Book> downloadedBooks = [];
  bool isOnlineMode = true;

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
    await _loadDownloadedBooks();
  }

  Future<void> _loadDownloadedBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> downloadedBookIds =
        prefs.getStringList('downloadedBooks') ?? [];
    setState(() {
      downloadedBooks = allBooks
          .where((book) => downloadedBookIds.contains(book.id))
          .toList();
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> downloadedBookIds =
        prefs.getStringList('downloadedBooks') ?? [];
    if (!downloadedBookIds.contains(book.id)) {
      downloadedBookIds.add(book.id);
      await prefs.setStringList('downloadedBooks', downloadedBookIds);
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
        title: const Text('E Books 👅'),
        actions: [
          Switch(
            value: isOnlineMode,
            onChanged: _toggleOnlineMode,
          ),
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
      body: isOnlineMode
          ? _buildOnlineContent()
          : Center(
              child: ElevatedButton(
                child: Text('Lihat Buku yang Diunduh'),
                onPressed: () => _toggleOnlineMode(false),
              ),
            ),
    );
  }

  Widget _buildOnlineContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Rekomendasi Hari Ini 🤪',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 350,
          child: recommendedBooks.isEmpty
              ? const Center(child: Text('Tidak ada rekomendasi'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedBooks.length,
                  itemBuilder: (context, index) {
                    final book = recommendedBooks[index];
                    final bool isDownloaded = downloadedBooks.contains(book);
                    return GestureDetector(
                      onTap: () => _navigateToBookDetail(book),
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: SizedBox(
                          width: 180,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: book.cover_image,
                                  width: 120,
                                  height: 180,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                        child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: Colors.grey[200],
                                    child: Icon(Icons.book,
                                        color: Colors.grey[600], size: 30),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      book.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      book.author,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rp ${book.price?.toStringAsFixed(0) ?? 'N/A'}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_shopping_cart,
                                        size: 20),
                                    onPressed: () => _addToCart(book),
                                    tooltip: 'Tambahkan ke keranjang',
                                  ),
                                  if (!isDownloaded)
                                    IconButton(
                                      icon:
                                          const Icon(Icons.download, size: 20),
                                      onPressed: () => _downloadBook(book),
                                      tooltip: 'Unduh buku',
                                    )
                                  else
                                    Icon(Icons.check,
                                        color: Colors.green, size: 20),
                                ],
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
            'Semua Buku 🤗',
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: allBooks.length,
            itemBuilder: (context, index) {
              final book = allBooks[index];
              final bool isDownloaded = downloadedBooks.contains(book);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: book.cover_image,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[200],
                        child:
                            Icon(Icons.book, color: Colors.grey[600], size: 30),
                      ),
                    ),
                  ),
                  title: Text(
                    book.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(book.author),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${book.price?.toStringAsFixed(0) ?? 'N/A'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () => _addToCart(book),
                        tooltip: 'Tambahkan ke keranjang',
                      ),
                      if (!isDownloaded)
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () => _downloadBook(book),
                          tooltip: 'Unduh buku',
                        )
                      else
                        Icon(Icons.check, color: Colors.green),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () => _navigateToBookDetail(book),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
