import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'book.dart';
import 'book_detail_page.dart';
import 'helpers/database_helper.dart';

class DownloadedBooksPage extends StatefulWidget {
  final List<Book> downloadedBooks;
  final Function(Book) onDeleteBook;

  const DownloadedBooksPage({
    Key? key,
    required this.downloadedBooks,
    required this.onDeleteBook,
  }) : super(key: key);

  @override
  _DownloadedBooksPageState createState() => _DownloadedBooksPageState();
}

class _DownloadedBooksPageState extends State<DownloadedBooksPage> {
  late List<Book> _downloadedBooks;

  @override
  void initState() {
    super.initState();
    _downloadedBooks = List.from(widget.downloadedBooks);
  }

  Future<void> _deleteDownloadedBook(Book book) async {
    try {
      await DatabaseHelper.instance.removeFromDownloaded(book.id);
      setState(() {
        _downloadedBooks.remove(book);
      });
      widget.onDeleteBook(book);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book.title} berhasil dihapus dari unduhan')),
      );
    } catch (e) {
      print('Error deleting downloaded book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus buku')),
      );
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

  void _goBackToHomePage() {
    Navigator.of(context).pop(); // Go back to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBackToHomePage();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Buku yang Diunduh',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios), // Updated icon
            onPressed: _goBackToHomePage,
          ),
        ),
        body: _downloadedBooks.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.library_books,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tidak ada buku yang diunduh',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Unduh buku untuk membacanya secara offline',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(12),
                child: ListView.builder(
                  itemCount: _downloadedBooks.length,
                  itemBuilder: (context, index) {
                    final book = _downloadedBooks[index];
                    return Dismissible(
                      key: Key(book.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) => _deleteDownloadedBook(book),
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _navigateToBookDetail(book),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: book.cover_image,
                                    width: 70,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey[200],
                                      child: Icon(
                                        Icons.book,
                                        color: Colors.grey[600],
                                        size: 30,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book.title,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        book.author,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.download_done,
                                            size: 16,
                                            color: Colors.green[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Tersedia offline',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red[400],
                                  onPressed: () => _deleteDownloadedBook(book),
                                  tooltip: 'Hapus unduhan',
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
      ),
    );
  }
}
