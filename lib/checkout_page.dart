import 'package:flutter/material.dart';
import 'book.dart';

class CheckoutPage extends StatelessWidget {
  final List<Book> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  Widget build(BuildContext context) {
    double total = cartItems.fold(0, (sum, item) => sum + (item.price ?? 0));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartItems.isEmpty
          ? const Center(
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
                        leading: const Icon(Icons.book),
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
                      const Text('Total:',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('Rp ${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Implementasi proses checkout di sini
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pembelian berhasil!')),
                      );
                      Navigator.of(context).pop(
                          true); // Mengembalikan true ketika pembayaran selesai
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text('Selesaikan Pembelian'),
                  ),
                ),
              ],
            ),
    );
  }
}
