import 'dart:io';

import 'package:chip_pos/database/db_helper.dart' as db;
import 'package:chip_pos/database/product.dart';
import 'package:chip_pos/database/sync_helper.dart';
import 'package:chip_pos/styles/stylbttn.dart';
import 'package:chip_pos/styles/style.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final db.DatabaseHelper dbHelper = db.DatabaseHelper();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  String? imagePath;

  Future<void> _selectImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  bool _validateInputs() {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        stockController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return false;
    }
    return true;
  }

  Future<void> _addProduct() async {
    if (!_validateInputs()) return;

    try {
      String name = nameController.text;
      double price = double.parse(priceController.text);
      int stock = int.parse(stockController.text);
      String? imageUrl;

      if (imagePath != null) {
        File imageFile = File(imagePath!);
        imageUrl = await _uploadImage(imageFile);
      }

      Product newProduct = Product(
        name: name,
        price: price,
        stock: stock,
        imageUrl: imageUrl,
      );
      await dbHelper.insertProduct(newProduct);
      await syncDataToFirebase(dbHelper);
      nameController.clear();
      priceController.clear();
      stockController.clear();
      setState(() {
        imagePath = null;
      });
      _showSuccessDialog();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Berhasil menambahkan menu'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Product', style: TextStyles.titleApp),
        backgroundColor: AppColors.bg,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Nama Product',
                labelStyle: TextStyle(color: AppColors.hitamgelap),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.hitamgelap, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.hitamgelap, width: 2.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'Harga',
                labelStyle: TextStyle(color: AppColors.hitamgelap),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.hitamgelap, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.hitamgelap, width: 2.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            TextField(
              controller: stockController,
              decoration: InputDecoration(
                labelText: 'Stock',
                labelStyle: TextStyle(color: AppColors.hitamgelap),
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.hitamgelap, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.hitamgelap, width: 2.0),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 22),
            Bttnstyl(
              child: SizedBox(
                height: 30,
                width: 150,
                child: ElevatedButton(
                  style: raisedButtonStyle,
                  onPressed: _selectImage,
                  child: Text('Pilih Gambar'),
                ),
              ),
            ),
            if (imagePath != null)
              Image.file(
                File(imagePath!),
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 22),
            Bttnstyl(
              child: ElevatedButton(
                style: raisedButtonStyle,
                onPressed: _addProduct,
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
          ],
        ),
      ),
    );
  }
}
