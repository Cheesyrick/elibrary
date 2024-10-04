import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'book.dart';
import 'book_detail_page.dart';

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> downloadedBookIds =
        prefs.getStringList('downloadedBooks') ?? [];
    if (downloadedBookIds.contains(book.id)) {
      downloadedBookIds.remove(book.id);
      await prefs.setStringList('downloadedBooks', downloadedBookIds);
      setState(() {
        _downloadedBooks.remove(book);
      });
      widget.onDeleteBook(book);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${book.title} berhasil dihapus dari unduhan')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buku yang Diunduh'),
      ),
      body: _downloadedBooks.isEmpty
          ? const Center(child: Text('Tidak ada buku yang diunduh'))
          : ListView.builder(
              itemCount: _downloadedBooks.length,
              itemBuilder: (context, index) {
                final book = _downloadedBooks[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      book.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(book.author),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteDownloadedBook(book),
                      tooltip: 'Hapus unduhan',
                    ),
                    onTap: () => _navigateToBookDetail(book),
                  ),
                );
              },
            ),
    );
  }
}
