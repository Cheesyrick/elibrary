import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/cart_provider.dart';
import './checkout_page.dart';
import 'book.dart';

class ProfileScreen extends StatelessWidget {
  // Data dummy untuk contoh
  List<Book> cartItems = [];
  final String userName = "User 1";
  final String userEmail = "user1@email.com";

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

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
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Saya'),
        backgroundColor: const Color.fromARGB(255, 138, 138, 138),
      ),
      body: Column(
        children: [
          // Header Profile
          Container(
            padding: EdgeInsets.all(20),
            color: const Color.fromARGB(255, 211, 211, 211),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Menu Items
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Keranjang Saya'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${cart.items.length}'),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios),
              ],
            ),
            onTap: _goToCheckout,
          ),

          Divider(),

          ListTile(
            leading: Icon(Icons.history),
            title: Text('Riwayat Pembelian'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigasi ke halaman riwayat
            },
          ),
        ],
      ),
    );
  }
}
