import 'package:chip_pos/page/order_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:chip_pos/styles/style.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Menangani tombol back perangkat dan kembali ke halaman pertama (home)
        Navigator.popUntil(context, (route) => route.isFirst);
        return false; // Menghentikan navigasi default
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'History Penjualan',
            style: TextStyles.titleApp,
          ),
          backgroundColor: AppColors.bg,
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('orderHistory')
              .orderBy('timestamp',
                  descending: true) // Mengurutkan dari terbaru
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('Tidak ada riwayat pesanan saat ini.'));
            }

            final orders = snapshot.data!.docs;

            // Menghitung total pendapatan
            double totalPendapatan = 0;
            for (var order in orders) {
              var orderData = order.data() as Map<String, dynamic>;
              totalPendapatan += orderData['total'];
            }

            return Column(
              children: [
                // Menampilkan total pendapatan
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Pendapatan',
                        style: TextStyles.deskriptom.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16), // Jarak antara teks dan nilai
                      Icon(
                        Icons.arrow_upward, // Tanda panah ke atas
                        color: Colors.green, // Warna hijau
                        size: 20,
                      ),
                      // Menampilkan total pendapatan
                      Text(
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ')
                            .format(totalPendapatan),
                        style: TextStyles.deskriptom,
                      ),
                    ],
                  ),
                ),
                // Daftar pesanan
                Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      var order = orders[index].data() as Map<String, dynamic>;
                      var products = order['products'] as List<dynamic>;
                      double totalOrderPrice = order['total'];

                      // Memastikan timestamp tidak null sebelum memanggil toDate
                      DateTime orderDate;
                      if (order['timestamp'] != null) {
                        orderDate = order['timestamp'].toDate();
                      } else {
                        orderDate = DateTime
                            .now(); // Atau bisa Anda set ke waktu default
                      }

                      // Mengelompokkan produk berdasarkan nama
                      Map<String, Map<String, dynamic>> groupedProducts = {};
                      for (var product in products) {
                        String productName = product['name'];
                        double productPrice = product['price'];
                        int productQuantity = product['quantity'];

                        if (groupedProducts.containsKey(productName)) {
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
                        margin: EdgeInsets.all(8.0),
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tanggal: ${DateFormat('dd-MM-yyyy HH:mm').format(orderDate)}',
                                style: TextStyles.deskriptom,
                              ),
                              const SizedBox(height: 8.0),
                              // Menampilkan produk yang dikelompokkan
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: groupedProducts.entries.map((entry) {
                                  return Text(
                                    '${entry.key} - ${entry.value['quantity']}x - ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(entry.value['price'])}',
                                    style: TextStyles.deskriptom,
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(totalOrderPrice)}',
                                style: TextStyles.deskriptom
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              // Tombol Edit
                              // Tombol Edit
                              ElevatedButton(
                                onPressed: () async {
                                  final orderId = orders[index].id;
                                  final orderData = orders[index].data()
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
                                      builder: (context) => OrderPage(
                                        orderId: orderId,
                                        initialOrderData: orderData,
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Edit'),
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
    );
  }
}

// Halaman EditOrderPage (perlu Anda buat)
class EditOrderPage extends StatelessWidget {
  final String orderId;

  EditOrderPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Order'),
      ),
      body: Center(
        child: Text('Edit order dengan ID: $orderId'),
      ),
    );
  }
}
