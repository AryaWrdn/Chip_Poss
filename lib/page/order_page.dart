import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:chip_pos/page/history_page.dart';
import 'package:chip_pos/styles/stylbttn.dart';
import 'package:chip_pos/styles/style.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> selectedProducts = [];
  double totalBill = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProductsFromFirebase();
  }

  Future<void> _fetchProductsFromFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('products').get();
    setState(() {
      products = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'],
          'stock': data['stock'],
          'price': data['price'],
          'imageUrl': data['imageUrl'] ?? '',
        };
      }).toList();
    });
  }

  void _addToBill(Map<String, dynamic> product) {
    setState(() {
      // Cek jika produk sudah ada di selectedProducts
      final existingProductIndex =
          selectedProducts.indexWhere((p) => p['id'] == product['id']);

      if (existingProductIndex != -1) {
        // Jika produk sudah ada, update jumlahnya
        selectedProducts[existingProductIndex]['quantity'] += 1;
      } else {
        // Jika produk belum ada, tambahkan ke selectedProducts
        selectedProducts.add({
          ...product,
          'quantity': 1, // Tambahkan jumlah produk
        });
      }

      totalBill += product['price'];
      product['stock'] -= 1;
      _updateProductStockInFirebase(product);
    });
    _showSnackBar('${product['name']} ditambahkan ke bill');
  }

  void _updateProductStockInFirebase(Map<String, dynamic> product) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('products').doc(product['id']).update({
        'stock': product['stock'],
      });
      debugPrint('Stok produk berhasil diperbarui di Firebase!');
    } catch (error) {
      _showErrorSnackBar('Gagal memperbarui stok produk: $error');
    }
  }

  void _uploadOrderHistoryToFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('orderHistory').add({
        'products': selectedProducts.map((product) {
          return {
            'name': product['name'],
            'price': product['price'],
            'quantity': product['quantity'], // Gunakan kuantitas yang benar
          };
        }).toList(),
        'total': totalBill,
        'timestamp': FieldValue.serverTimestamp(),
      });
      debugPrint('Riwayat pesanan berhasil di-upload!');
    } catch (error) {
      _showErrorSnackBar('Gagal meng-upload riwayat pesanan: $error');
    }
  }

  void _completeOrder() {
    if (selectedProducts.isEmpty) {
      _showErrorSnackBar('Silakan pilih produk sebelum menyelesaikan order');
      return;
    }

    _uploadOrderHistoryToFirebase();

    // Reset untuk menampilkan halaman history
    setState(() {
      selectedProducts.clear();
      totalBill = 0.0;
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryPage()),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showErrorSnackBar(String message) {
    _showSnackBar(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Menu', style: TextStyles.titleApp),
        backgroundColor: AppColors.bg,
      ),
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(color: AppColors.background),
          ),
          Column(
            children: [
              Flexible(
                flex: 3,
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> product = products[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6.0),
                                child: product['imageUrl'].isNotEmpty
                                    ? Image.network(product['imageUrl'],
                                        fit: BoxFit.cover)
                                    : Image.asset('assets/images/1.jpeg',
                                        fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text('Stok: ${product['stock']}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(product['price'])}',
                                    style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_shopping_cart),
                              onPressed: () => _addToBill(product),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(color: AppColors.abuabuabu, thickness: 2),
              const Text(
                  '||||----------------------Bill----------------------||||',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(color: AppColors.abuabuabu, thickness: 2),
              Flexible(
                flex: 1,
                child: ListView.builder(
                  itemCount: selectedProducts.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> product = selectedProducts[index];
                    return ListTile(
                      title: Text(
                          '${product['name']} ${product['quantity']}x'), // Tampilkan jumlah produk
                      subtitle: Text(
                        'Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(product['price'])}',
                        style: TextStyles.deskriptom,
                      ),
                    );
                  },
                ),
              ),
              const Divider(color: AppColors.abuabuabu, thickness: 2),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(totalBill)}',
                  style: TextStyles.deskriptom,
                ),
              ),
              Bttnstyl(
                child: ElevatedButton(
                  style: raisedButtonStyle,
                  onPressed: _completeOrder,
                  child: SizedBox(
                    width: 320,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Selesai',
                          textAlign: TextAlign.center,
                          style: TextStyles.title
                              .copyWith(fontSize: 20.0, color: Colors.white)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
