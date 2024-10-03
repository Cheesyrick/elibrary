import 'package:flutter/material.dart';

/* i like man */
class CategoryPage extends StatelessWidget {
  final String category;

  const CategoryPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category Books'),
      ),
      body: Center(
        child: Text('List of books for $category'),
      ),
    );
  }
}
