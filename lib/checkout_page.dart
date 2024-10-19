import 'package:flutter/material.dart';
import 'book.dart';

class CheckoutPage extends StatelessWidget {
  final List<Book> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  Future<void> _processCheckout(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    await Future.delayed(const Duration(seconds: 2));

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pembelian berhasil!')),
    );

    Navigator.of(context).pop(true);
  }

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
                    onPressed: () => _processCheckout(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Selesaikan Pembelian'),
                  ),
                ),
              ],
            ),
    );
  }
}
