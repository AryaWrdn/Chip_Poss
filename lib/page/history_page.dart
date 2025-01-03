import 'package:chip_pos/page/order_page.dart';
import 'package:chip_pos/styles/stylbttn.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:chip_pos/styles/style.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.popUntil(context, (route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'History Penjualan',
            style: TextStyles.titleApp,
          ),
          backgroundColor: AppColors.bg,
        ),
        body: Container(
          height: 785,
          child: Stack(children: [
            Container(
              height: 785,
              decoration: BoxDecoration(
                color: const Color.fromARGB(154, 203, 200, 185),
              ),
            ),
            Container(
              height: 135,
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
              height: 130,
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
            Column(
              children: [
                // Input Pencarian
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 1),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                      suffixIcon: Icon(Icons.search, color: Colors.grey),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery =
                            value.toLowerCase(); // Normalisasi teks pencarian
                      });
                    },
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('orderHistory')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text('Tidak ada riwayat pesanan saat ini.'),
                        );
                      }

                      final orders = snapshot.data!.docs;

                      // Filter pesanan berdasarkan pencarian
                      final filteredOrders = orders.where((order) {
                        final orderData = order.data() as Map<String, dynamic>;
                        final ownerName = (orderData['ownerName'] ?? '')
                            .toString()
                            .toLowerCase();
                        return ownerName.contains(_searchQuery);
                      }).toList();

                      if (filteredOrders.isEmpty) {
                        return Center(
                          child: Text('Tidak ada hasil yang sesuai.'),
                        );
                      }

                      // Menghitung total pendapatan dari hasil pencarian
                      double totalPendapatan = 0;
                      for (var order in filteredOrders) {
                        var orderData = order.data() as Map<String, dynamic>;
                        totalPendapatan += orderData['total'];
                      }

                      return Column(
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Pendapatan',
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
                                        .format(totalPendapatan),
                                    style: TextStyles.deskriptom,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Daftar Pesanan
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                var order = filteredOrders[index].data()
                                    as Map<String, dynamic>;
                                var products =
                                    order['products'] as List<dynamic>;
                                double totalOrderPrice = order['total'];
                                DateTime orderDate =
                                    order['timestamp']?.toDate() ??
                                        DateTime.now();

                                // Mengelompokkan produk berdasarkan nama
                                Map<String, Map<String, dynamic>>
                                    groupedProducts = {};
                                for (var product in products) {
                                  String productName = product['name'];
                                  double productPrice = product['price'];
                                  int productQuantity = product['quantity'];

                                  if (groupedProducts
                                      .containsKey(productName)) {
                                    groupedProducts[productName]!['quantity'] +=
                                        productQuantity;
                                  } else {
                                    groupedProducts[productName] = {
                                      'price': productPrice,
                                      'quantity': productQuantity,
                                    };
                                  }
                                }

                                return Card(
                                  color:
                                      const Color.fromARGB(255, 197, 175, 131),
                                  margin: EdgeInsets.all(8.0),
                                  elevation: 4,
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Nama: ${order['ownerName'] ?? 'Tidak Diketahui'}',
                                          style: TextStyles.deskriptom.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),

                                        Text(
                                          'Tanggal: ${DateFormat('dd-MM-yyyy HH:mm').format(orderDate)}',
                                          style: TextStyles.deskriptom,
                                        ),
                                        const SizedBox(height: 8.0),
                                        // Menampilkan Produk yang Dikelompokkan
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: groupedProducts.entries
                                              .map((entry) {
                                            return Text(
                                              '${entry.key} - ${entry.value['quantity']}x',
                                              style: TextStyles.deskriptom,
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 16.0),
                                        Text(
                                          'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(totalOrderPrice)}',
                                          style: TextStyles.deskriptom.copyWith(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 8.0),
                                        Container(
                                          height: 40,
                                          child: Bttnstyl(
                                            child: ElevatedButton(
                                              style: raisedButtonStyle,
                                              onPressed: () async {
                                                final orderId =
                                                    filteredOrders[index].id;
                                                final orderData =
                                                    filteredOrders[index].data()
                                                        as Map<String, dynamic>;

                                                // Menghapus data lama dari Firebase
                                                await FirebaseFirestore.instance
                                                    .collection('orderHistory')
                                                    .doc(orderId)
                                                    .delete();

                                                // Pindah ke halaman Edit
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderPage(
                                                      orderId: orderId,
                                                      initialOrderData:
                                                          orderData,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: SizedBox(
                                                width: 120,
                                                child: Text(
                                                  'Edit',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyles.title
                                                      .copyWith(
                                                          fontSize: 16.0,
                                                          color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
