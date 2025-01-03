import 'dart:async'; // Untuk StreamSubscription
import 'dart:io';
import 'package:chip_pos/styles/style.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Tambahkan package ini
import 'package:chip_pos/database/db_helper.dart' as db;
import 'package:chip_pos/database/product.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class StockPage extends StatefulWidget {
  const StockPage({Key? key}) : super(key: key);

  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final db.DatabaseHelper dbHelper = db.DatabaseHelper();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<Product> products = [];
  String? imagePath;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _syncFirestoreToSQLite();

    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      if (result.isNotEmpty) {
        _syncSQLiteToFirestore(); // Sinkronisasi saat online
      }
    });

    // Menambahkan listener untuk mengawasi perubahan di Firestore
    firestore.collection('products').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.removed) {
          // Jika dokumen dihapus dari Firestore
          int id = int.parse(change.doc.id);
          _deleteProductFromSQLite(id); // Hapus dari SQLite
        }
      }
    });
  }

  Future<void> _syncFirestoreToSQLite() async {
    QuerySnapshot snapshot = await firestore.collection('products').get();
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      Product product = Product(
        id: int.parse(doc.id),
        name: data['name'],
        price: data['price'],
        stock: data['stock'],
        imageUrl: data['imageUrl'],
      );

      await dbHelper.insertOrUpdateProduct(product);
    }
    _loadProducts();
  }

  Future<void> _syncSQLiteToFirestore() async {
    List<Product> localProducts = await dbHelper.getProducts();
    for (var product in localProducts) {
      await firestore
          .collection('products')
          .doc(product.id.toString())
          .set(product.toMap());
    }
  }

  Future<void> _loadProducts() async {
    List<Product> list = await dbHelper.getProducts();
    if (mounted) {
      setState(() {
        products = list;
      });
    }
  }

  Future<void> _deleteProduct(int id) async {
    await dbHelper.deleteProduct(id); // Hapus produk dari SQLite

    // Hapus produk dari Firestore hanya jika online
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      await firestore.collection('products').doc(id.toString()).delete();
    }

    if (mounted) {
      _loadProducts(); // Memanggil _loadProducts untuk menyegarkan halaman
    }
  }

  Future<void> _deleteProductFromSQLite(int id) async {
    await dbHelper.deleteProduct(id);
    await _loadProducts(); // Refresh tampilan produk setelah penghapusan
  }

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      String filePath = 'products/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageRef = FirebaseStorage.instance.ref().child(filePath);
      await storageRef.putFile(imageFile);
      return await storageRef.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateProduct(Product product) async {
    nameController.text = product.name;
    priceController.text = product.price.toString();
    stockController.text = product.stock.toString();
    imagePath = product.imageUrl;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Nama Product'),
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stockController,
                  decoration: InputDecoration(labelText: 'Stock'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _selectImage,
                  child: Text('Pilih Gambar'),
                ),
                if (imagePath != null)
                  Container(
                    height: 200,
                    width: 200,
                    child: imagePath!.startsWith('http')
                        ? Image.network(imagePath!, fit: BoxFit.cover)
                        : Image.file(File(imagePath!), fit: BoxFit.cover),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                String? newImageUrl;
                if (imagePath != null && !imagePath!.startsWith('http')) {
                  File imageFile = File(imagePath!);
                  newImageUrl = await _uploadImage(imageFile);
                }

                Product updatedProduct = Product(
                  id: product.id,
                  name: nameController.text,
                  price: double.parse(priceController.text),
                  stock: int.parse(stockController.text),
                  imageUrl: newImageUrl ?? product.imageUrl,
                );

                // Memeriksa konektivitas sebelum menyimpan
                var connectivityResult =
                    await Connectivity().checkConnectivity();
                if (connectivityResult == ConnectivityResult.mobile ||
                    connectivityResult == ConnectivityResult.wifi) {
                  // Jika terhubung, simpan ke Firestore
                  await firestore
                      .collection('products')
                      .doc(updatedProduct.id.toString())
                      .set(updatedProduct.toMap());
                } else {
                  // Jika tidak terhubung, simpan ke SQLite
                  await dbHelper.updateProduct(updatedProduct);
                }

                Navigator.of(context).pop();
                _loadProducts();
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription
        ?.cancel(); // Hentikan subscription saat widget dibuang
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Stock Management'),
        backgroundColor: AppColors.bg,
      ),
      body: Container(
        child: Stack(
          children: [
            Container(
              height: 785,
              decoration: BoxDecoration(
                color: const Color.fromARGB(154, 203, 200, 185),
              ),
            ),
            Container(
              height: 105,
              decoration: BoxDecoration(
                color: AppColors.merah,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50.0),
                  bottomRight: Radius.circular(50.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50.0),
                  bottomRight: Radius.circular(50.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
            ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                Product product = products[index];
                return Card(
                  color: const Color.fromARGB(255, 197, 175, 131),
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Mengatur alignment gambar di atas informasi produk
                          children: [
                            // Gambar Produk di Kiri
                            product.imageUrl != null &&
                                    product.imageUrl!.isNotEmpty
                                ? Container(
                                    height: 100,
                                    width: 100,
                                    child: Image.network(
                                      product.imageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    height: 100,
                                    width: 100,
                                    color: Colors.grey[200],
                                    child: Center(
                                        child: Icon(Icons.image,
                                            color: Colors.grey)),
                                  ),
                            SizedBox(width: 16),
                            // Informasi Produk di Kiri
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Stok: ${product.stock}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Harga: ${product.price}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .end, // Membuat ikon di sebelah kanan
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.white),
                                onPressed: () => _updateProduct(product),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProduct(product.id!),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
