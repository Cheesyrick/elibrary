import 'package:flutter/material.dart';
import 'book.dart';

class CheckoutPage extends StatelessWidget {
  final List<Book> cartItems;

  const CheckoutPage({Key? key, required this.cartItems}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(0, (sum, item) => sum + (item.price ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                'Tidak ada item di keranjang',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Icon(Icons.book),
                        title: Text(cartItems[index].title),
                        subtitle: Text(cartItems[index].author),
                        trailing: Text(
                            'Rp ${cartItems[index].price?.toStringAsFixed(0) ?? 'N/A'}'),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Rp ${total.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    child: Text('Selesaikan Pembelian'),
                    onPressed: () {
                      // Implementasi proses checkout di sini
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Pembelian berhasil!')),
                      );
                      Navigator.of(context).pop(
                          true); // Mengembalikan true ketika pembayaran selesai
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
