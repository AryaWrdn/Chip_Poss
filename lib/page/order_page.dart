import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:chip_pos/database/db_helper.dart';
import 'package:chip_pos/database/product.dart';
import 'package:chip_pos/page/history_page.dart';
import 'package:chip_pos/styles/stylbttn.dart';
import 'package:chip_pos/styles/style.dart';

List<Map<String, dynamic>> orderHistory = [];

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final dbHelper = DatabaseHelper();
  List<Product> products = [];
  List<Product> selectedProducts = [];
  double totalBill = 0.0;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    List<Product> list = await dbHelper.getProducts();
    setState(() {
      products = list;
    });
  }

  void _uploadStockToFirebase(Product product) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('products').doc(product.id.toString()).set({
        'name': product.name,
        'stock': product.stock,
        'price': product.price,
      });
      debugPrint('Stok produk berhasil di-upload!');
    } catch (error) {
      _showErrorSnackBar('Gagal meng-upload stok produk: $error');
    }
  }

  void _addToBill(Product product) {
    if (product.stock > 0) {
      setState(() {
        selectedProducts.add(product);
        totalBill += product.price;
        product.stock -= 1;
        dbHelper.updateProduct(product);
        _uploadStockToFirebase(product);
      });
      _showSnackBar('${product.name} ditambahkan ke bill');
    } else {
      _showErrorSnackBar('Stok tidak cukup untuk ${product.name}');
    }
  }

  void _uploadOrderHistoryToFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('orderHistory').add({
        'products': selectedProducts.map((product) {
          return {
            'name': product.name,
            'price': product.price,
            'quantity': 1,
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

    orderHistory.add({
      'products': selectedProducts.map((product) {
        return {
          'name': product.name,
          'price': product.price,
          'quantity': 1,
        };
      }).toList(),
      'total': totalBill,
    });

    setState(() {
      selectedProducts.clear();
      totalBill = 0.0;
    });

    _uploadOrderHistoryToFirebase();

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
          Container(
            height: 453,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 180, 181, 168), // Warna solid di atas
                  Color.fromARGB(
                      0, 138, 141, 99), // Warna yang lebih transparan di bawah
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 80,
                  offset: Offset(0, 5),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Flexible(
                flex: 3,
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    Product product = products[index];
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
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      6.0), // Radius border
                                  child: product.imageUrl != null &&
                                          product.imageUrl!.isNotEmpty
                                      ? Image.network(
                                          product.imageUrl!,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/images/1.jpeg', // Path gambar default
                                          fit: BoxFit.cover,
                                        ),
                                )),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Stok: ${product.stock}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(product.price)}',
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
                    Product product = selectedProducts[index];
                    return ListTile(
                      title: Text(product.name),
                      subtitle: Text(
                        'Harga: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(product.price)}',
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
                      child: Text(
                        'Selesai',
                        textAlign: TextAlign.center,
                        style: TextStyles.title
                            .copyWith(fontSize: 20.0, color: Colors.white),
                      ),
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
