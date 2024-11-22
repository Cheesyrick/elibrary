import 'package:flutter/material.dart';
import 'book.dart';

class BookReaderPage extends StatefulWidget {
  final Book book;

  const BookReaderPage({Key? key, required this.book}) : super(key: key);

  @override
  _BookReaderPageState createState() => _BookReaderPageState();
}

class _BookReaderPageState extends State<BookReaderPage> {
  double _fontSize = 16.0;
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.text_fields,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: _showFontSizeDialog,
          ),
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: _isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: Container(
        color: _isDarkMode ? Colors.black : Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.book.title,
                style: TextStyle(
                  fontSize: _fontSize + 8,
                  fontWeight: FontWeight.bold,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'by ${widget.book.author}',
                style: TextStyle(
                  fontSize: _fontSize - 2,
                  color: _isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                widget.book.synopsis, // Replace with actual book content
                style: TextStyle(
                  fontSize: _fontSize,
                  height: 1.5,
                  color: _isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ukuran Teks'),
        content: StatefulBuilder(
          builder: (context, setState) => Slider(
            value: _fontSize,
            min: 12,
            max: 24,
            divisions: 12,
            label: _fontSize.round().toString(),
            onChanged: (value) {
              setState(() {
                _fontSize = value;
              });
              this.setState(() {});
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
