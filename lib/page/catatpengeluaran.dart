import 'package:chip_pos/styles/stylbttn.dart';
import 'package:chip_pos/styles/style.dart';
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
    _hitungPendapatanTersisa();
  }

  Future<void> _hitungPendapatanTersisa() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('pengeluaran').get();
    double totalPengeluaran = snapshot.docs
        .fold(0, (sum, doc) => sum + (doc['hargaBarang'] as double));
    setState(() {
      pendapatanTersisa = widget.totalPendapatan - totalPengeluaran;
    });
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

    FirebaseFirestore.instance.collection('pengeluaran').add({
      'namaBarang': namaBarang,
      'hargaBarang': hargaBarang,
      'tanggal': DateTime.now(),
    }).then((_) {
      _hitungPendapatanTersisa();
      _namaBarangController.clear();
      _hargaBarangController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengeluaran berhasil dicatat')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catat Pengeluaran'),
        backgroundColor: AppColors.bg,
      ),
      body: Container(
        height: 785,
        child: Stack(
          children: [
            Container(
              height: 785,
              decoration: BoxDecoration(
                color: const Color.fromARGB(154, 203, 200, 185),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.abuabuabu,
                          width: 2,
                        ),
                        color: const Color.fromARGB(189, 248, 242, 221),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Pendapatan Tersisa',
                            style: TextStyles.deskriptom.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 16),
                          Icon(
                            Icons.arrow_upward,
                            color: Colors.green,
                            size: 20,
                          ),
                          Text(
                            NumberFormat.currency(
                                    locale: 'id_ID', symbol: 'Rp ')
                                .format(pendapatanTersisa),
                            style: TextStyles.deskriptom,
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextField(
                    controller: _namaBarangController,
                    decoration: InputDecoration(
                      labelText: 'Nama Barang',
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
                  SizedBox(height: 20),
                  TextField(
                    controller: _hargaBarangController,
                    decoration: InputDecoration(
                      labelText: 'Harga Barang',
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
                  SizedBox(height: 20),
                  Bttnstyl(
                    child: ElevatedButton(
                      style: raisedButtonStyle,
                      onPressed: _catatPengeluaran,
                      child: SizedBox(
                        width: 320,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            'Catat Pengeluaran',
                            textAlign: TextAlign.center,
                            style: TextStyles.title
                                .copyWith(fontSize: 20.0, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50),
                  const Divider(color: AppColors.abuabuabu, thickness: 2),
                  SizedBox(
                    child: Text(
                      'History Pengeluaran ',
                      style: TextStyles.heading,
                    ),
                  ),
                  const Divider(color: AppColors.abuabuabu, thickness: 2),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('pengeluaran')
                          .orderBy('tanggal', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final pengeluaranDocs = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: pengeluaranDocs.length,
                          itemBuilder: (context, index) {
                            final pengeluaran = pengeluaranDocs[index];
                            return ListTile(
                              title: Text(pengeluaran['namaBarang']),
                              trailing: Text(
                                NumberFormat.currency(
                                        locale: 'id_ID', symbol: 'Rp ')
                                    .format(pengeluaran['hargaBarang']),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
