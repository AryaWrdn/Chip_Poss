import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:chip_pos/page/history_page.dart';
import 'package:chip_pos/styles/stylbttn.dart';
import 'package:chip_pos/styles/style.dart';

class OrderPage extends StatefulWidget {
  final String? orderId;
  final Map<String, dynamic>? initialOrderData;

  const OrderPage({Key? key, this.orderId, this.initialOrderData})
      : super(key: key);

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> selectedProducts = [];
  Map<String, int> originalStock = {};
  double totalBill = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProductsFromFirebase();

    if (widget.initialOrderData != null) {
      _loadInitialOrderData(widget.initialOrderData!);
    }
  }

  Future<void> _fetchProductsFromFirebase() async {
    try {
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
      for (var product in products) {
        originalStock[product['id']] = product['stock'];
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  void _loadInitialOrderData(Map<String, dynamic> orderData) {
    setState(() {
      selectedProducts = List<Map<String, dynamic>>.from(orderData['products']);
      totalBill = orderData['total'];
    });
  }

  void _addToBill(Map<String, dynamic> product) {
    if (product['stock'] <= 0) {
      _showStockAlert(product['name']);
      return;
    }

    setState(() {
      final existingProductIndex =
          selectedProducts.indexWhere((p) => p['id'] == product['id']);

      if (existingProductIndex != -1) {
        // Jika produk sudah ada, tambahkan quantity-nya
        selectedProducts[existingProductIndex]['quantity'] += 1;
      } else {
        // Jika produk belum ada, tambahkan produk baru
        selectedProducts.add({
          ...product,
          'quantity': 1,
        });
      }

      // Update stok produk
      totalBill += product['price'];
      product['stock'] -= 1;
      _updateProductStockInFirebase(product);
    });

    _showSnackBar('${product['name']} ditambahkan ke bill');
  }

  void _showStockAlert(String productName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Stok Habis'),
          content: Text('Ups... stok untuk $productName telah habis.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _removeFromBill(Map<String, dynamic> product) {
    setState(() {
      final existingProductIndex =
          selectedProducts.indexWhere((p) => p['id'] == product['id']);
      if (existingProductIndex != -1) {
        if (selectedProducts[existingProductIndex]['quantity'] > 1) {
          selectedProducts[existingProductIndex]['quantity'] -= 1;
          totalBill -= product['price'];
        } else {
          selectedProducts.removeAt(existingProductIndex);
          totalBill -= product['price'];
        }
        product['stock'] += 1;
        _updateProductStockInFirebase(product);
      }
    });
    _showSnackBar('${product['name']} dikurangi dari bill');
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

  void _restoreOriginalStock() {
    for (var product in selectedProducts) {
      final originalQuantity = product['quantity'];
      final originalProduct =
          products.firstWhere((p) => p['id'] == product['id']);
      originalProduct['stock'] += originalQuantity;
      _updateProductStockInFirebase(originalProduct);
    }

    // Clear the selected products after restoring stock
    setState(() {
      selectedProducts.clear();
      totalBill = 0.0;
    });
  }

  void _uploadOrderHistoryToFirebase() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      await firestore.collection('orderHistory').add({
        'products': selectedProducts.map((product) {
          return {
            'id': product['id'],
            'name': product['name'],
            'price': product['price'] * product['quantity'],
            'quantity': product['quantity'],
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
    return WillPopScope(
      onWillPop: () async {
        // Menangani jika user menekan tombol back
        _restoreOriginalStock();
        return true;
      },
      child: Scaffold(
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
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add_shopping_cart),
                                    onPressed: () => _addToBill(product),
                                  ),
                                  IconButton(
                                    icon:
                                        const Icon(Icons.remove_shopping_cart),
                                    onPressed: () => _removeFromBill(product),
                                  ),
                                ],
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
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(color: AppColors.abuabuabu, thickness: 2),
                Flexible(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: selectedProducts.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> product = selectedProducts[index];
                      return ListTile(
                        title:
                            Text('${product['name']} x${product['quantity']}'),
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
      ),
    );
  }
}
