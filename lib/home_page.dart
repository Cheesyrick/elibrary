import 'package:flutter/material.dart';
import 'category_page.dart'; // Import the new file

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perpustakaan Online'),
      ),
      body: ListView(
        children: [
          // Book categories
          _buildCategory(context, 'Edukasi'),
          _buildCategory(context, 'Sains'),
          _buildCategory(context, 'Sejarah'),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategory(BuildContext context, String category) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(category),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CategoryPage(category: category),
            ),
          );
        },
      ),
    );
  }
}
