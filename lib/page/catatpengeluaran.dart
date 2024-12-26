import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CatatPengeluaran extends StatefulWidget {
  final double totalPendapatan;

  CatatPengeluaran({required this.totalPendapatan});

  @override
  _CatatPengeluaranState createState() => _CatatPengeluaranState();
}

class _CatatPengeluaranState extends State<CatatPengeluaran> {
  final TextEditingController _namaBarangController = TextEditingController();
  final TextEditingController _hargaBarangController = TextEditingController();
  double pendapatanTersisa = 0;

  @override
  void initState() {
    super.initState();
    pendapatanTersisa = widget.totalPendapatan;
  }

  void _catatPengeluaran() {
    final String namaBarang = _namaBarangController.text.trim();
    final String hargaBarangStr = _hargaBarangController.text.trim();

    if (namaBarang.isEmpty || hargaBarangStr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap isi semua field')),
      );
      return;
    }

    final double? hargaBarang = double.tryParse(hargaBarangStr);
    if (hargaBarang == null || hargaBarang <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harga barang harus angka valid')),
      );
      return;
    }

    // Update pendapatan tersisa
    setState(() {
      pendapatanTersisa -= hargaBarang;
    });

    // Simpan pengeluaran ke Firestore
    FirebaseFirestore.instance.collection('pengeluaran').add({
      'namaBarang': namaBarang,
      'hargaBarang': hargaBarang,
      'tanggal': DateTime.now(),
    });

    // Reset text field
    _namaBarangController.clear();
    _hargaBarangController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pengeluaran berhasil dicatat')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catat Pengeluaran'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Pendapatan Tersisa: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(pendapatanTersisa)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _namaBarangController,
              decoration: InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _hargaBarangController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Harga Barang',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _catatPengeluaran,
              child: Text('Catat Pengeluaran'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
