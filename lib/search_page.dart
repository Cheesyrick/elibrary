import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Book> allBooks = [];
  List<Book> filteredBooks = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    final String response = await rootBundle.loadString('assets/books.json');
    final List<dynamic> data = await json.decode(response);
    setState(() {
      allBooks = data.map((book) => Book.fromJson(book)).toList();
      filteredBooks = allBooks;
    });
  }

  void _filterBooks(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredBooks = allBooks;
      } else {
        filteredBooks = allBooks
            .where((book) =>
                book.title.toLowerCase().contains(query.toLowerCase()) ||
                book.author.toLowerCase().contains(query.toLowerCase()) ||
                book.subject.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cari Buku')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterBooks,
              decoration: InputDecoration(
                labelText: 'Cari judul, pengarang, atau kategori',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(filteredBooks[index].title),
                  subtitle: Text(filteredBooks[index].author),
                  trailing: Text(filteredBooks[index].subject),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Book {
  final String title;
  final String author;
  final String subject;

  Book({required this.title, required this.author, required this.subject});

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'],
      author: json['author'],
      subject: json['subject'],
    );
  }
}
