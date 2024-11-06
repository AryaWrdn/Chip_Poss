import 'package:chip_pos/page/order_page.dart';
import 'package:chip_pos/styles/style.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('Order History: $orderHistory');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History Penjualan',
          style: TextStyles.titleApp,
        ),
        backgroundColor: AppColors.bg,
      ),
      body: orderHistory.isEmpty
          ? Stack(
              children: [
                Container(
                  height: 800,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                  ),
                ),
                Container(
                  height: 453,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 180, 181, 168),
                        Color.fromARGB(0, 138, 141, 99),
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
                Center(
                  child: Text('Tidak ada riwayat pesanan saat ini.'),
                ),
              ],
            )
          : ListView.builder(
              itemCount: orderHistory.length,
              itemBuilder: (context, index) {
                var order = orderHistory[index];
                Map<String, Map<String, dynamic>> productMap = {};
                double totalOrderPrice = 0.0;
                for (var product in order['products']) {
                  var productName = product['name'];
                  var productPrice = product['price'];
                  var productQuantity = product['quantity'];

                  totalOrderPrice += productPrice * productQuantity;
                  if (productMap.containsKey(productName)) {
                    productMap[productName]!['quantity'] += productQuantity;
                  } else {
                    productMap[productName] = {
                      'price': productPrice,
                      'quantity': productQuantity,
                    };
                  }
                }

                return Stack(
                  children: [
                    Container(
                      height: 800,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                      ),
                    ),
                    Container(
                      height: 453,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color.fromARGB(255, 180, 181, 168),
                            Color.fromARGB(0, 138, 141, 99),
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
                    Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Pesanan #${index + 1}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...productMap.entries.map<Widget>((entry) {
                              var productName = entry.key;
                              var productDetails = entry.value;
                              var productPrice = productDetails['price'];
                              var productQuantity = productDetails['quantity'];
                              var totalPrice = productPrice * productQuantity;

                              print(
                                  'Menampilkan produk: $productName, Quantity: $productQuantity, Total: $totalPrice');

                              return Text(
                                '$productName                       $productQuantity x Rp $productPrice = Rp $totalPrice',
                                style: TextStyle(fontSize: 16),
                              );
                            }).toList(),
                            Divider(),
                            Text(
                              'Total Harga: Rp $totalOrderPrice',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
