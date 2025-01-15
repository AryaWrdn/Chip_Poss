// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';

// class SummaryPendapatanPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Ringkasan Pendapatan'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('orderHistory')
//               .where('timestamp',
//                   isGreaterThan: DateTime.now().subtract(Duration(days: 7)))
//               .snapshots(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(child: CircularProgressIndicator());
//             }

//             if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//               return Center(
//                 child: Text('Tidak ada data untuk minggu ini.'),
//               );
//             }

//             final orders = snapshot.data!.docs;

//             double totalPendapatan = 0;
//             double totalPengeluaran = 0;
//             for (var order in orders) {
//               final data = order.data() as Map<String, dynamic>;
//               totalPendapatan += data['total'] ?? 0;
//             }

//             return Column(
//               children: [
//                 // Card Total Pendapatan
//                 _buildSummaryCard(
//                   context,
//                   'Total Pendapatan Minggu Ini',
//                   totalPendapatan,
//                   Colors.green,
//                 ),

//                 // Card Total Pengeluaran
//                 StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('pengeluaran')
//                       .where('tanggal',
//                           isGreaterThan:
//                               DateTime.now().subtract(Duration(days: 7)))
//                       .snapshots(),
//                   builder: (context, pengeluaranSnapshot) {
//                     if (pengeluaranSnapshot.connectionState ==
//                         ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }

//                     if (pengeluaranSnapshot.hasData) {
//                       totalPengeluaran = pengeluaranSnapshot.data!.docs.fold(
//                         0.0,
//                         (sum, doc) => sum + (doc['hargaBarang'] as double),
//                       );
//                     }

//                     double sisaPendapatan = totalPendapatan - totalPengeluaran;

//                     return Column(
//                       children: [
//                         _buildSummaryCard(
//                           context,
//                           'Total Pengeluaran Minggu Ini',
//                           totalPengeluaran,
//                           Colors.red,
//                         ),
//                         _buildSummaryCard(
//                           context,
//                           'Sisa Pendapatan Minggu Ini',
//                           sisaPendapatan,
//                           Colors.orange,
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryCard(
//       BuildContext context, String title, double amount, Color color) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10.0),
//       child: ListTile(
//         tileColor: color.withOpacity(0.1),
//         title: Text(
//           title,
//           style: TextStyle(fontWeight: FontWeight.bold, color: color),
//         ),
//         trailing: Text(
//           NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(amount),
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//       ),
//     );
//   }
// }
import 'package:chip_pos/styles/style.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SummaryPendapatanPage extends StatelessWidget {
  // Function to calculate total revenue from all orders
  Future<double> _hitungTotalPendapatanKeseluruhan() async {
    double totalPendapatan = 0;
    final ordersSnapshot =
        await FirebaseFirestore.instance.collection('orderHistory').get();
    for (var order in ordersSnapshot.docs) {
      final data = order.data(); // No need to cast here
      totalPendapatan += data['total'] ?? 0;
    }
    return totalPendapatan;
  }

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
            'Pembukuan',
            style: TextStyles.titleApp,
          ),
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
                    FutureBuilder<double>(
                      future: _hitungTotalPendapatanKeseluruhan(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }

                        final totalPendapatanKeseluruhan = snapshot.data!;
                        return Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
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
                                    color: const Color.fromARGB(
                                        189, 248, 242, 221),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        'Asset',
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
                                            .format(totalPendapatanKeseluruhan),
                                        style: TextStyles.deskriptom,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orderHistory')
                          .where('timestamp',
                              isGreaterThan:
                                  DateTime.now().subtract(Duration(days: 7)))
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(
                              child: Text('Tidak ada data untuk minggu ini.'));
                        }

                        final orders = snapshot.data!.docs;
                        double totalPendapatan = 0;
                        for (var order in orders) {
                          final data = order.data() as Map<String, dynamic>;
                          totalPendapatan += data['total'] ?? 0;
                        }

                        return _buildSummaryCard(
                          context,
                          'Total Pendapatan Minggu Ini',
                          totalPendapatan,
                          Colors.green,
                        );
                      },
                    ),

                    // Display total expenditures for the current week
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('pengeluaran')
                          .where('tanggal',
                              isGreaterThan:
                                  DateTime.now().subtract(Duration(days: 7)))
                          .snapshots(),
                      builder: (context, pengeluaranSnapshot) {
                        if (pengeluaranSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        double totalPengeluaran = 0;
                        if (pengeluaranSnapshot.hasData) {
                          totalPengeluaran =
                              pengeluaranSnapshot.data!.docs.fold(
                            0.0,
                            (sum, doc) => sum + (doc['hargaBarang'] as double),
                          );
                        }

                        return _buildSummaryCard(
                          context,
                          'Total Pengeluaran Minggu Ini',
                          totalPengeluaran,
                          Colors.red,
                        );
                      },
                    ),

                    // Display remaining revenue for the current week
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('orderHistory')
                          .where('timestamp',
                              isGreaterThan:
                                  DateTime.now().subtract(Duration(days: 7)))
                          .snapshots(),
                      builder: (context, ordersSnapshot) {
                        if (ordersSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!ordersSnapshot.hasData ||
                            ordersSnapshot.data!.docs.isEmpty) {
                          return Center(
                              child: Text('Tidak ada data untuk minggu ini.'));
                        }

                        double totalPendapatan = 0;
                        for (var order in ordersSnapshot.data!.docs) {
                          final data = order.data() as Map<String, dynamic>;
                          totalPendapatan += data['total'] ?? 0;
                        }

                        return StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('pengeluaran')
                              .where('tanggal',
                                  isGreaterThan: DateTime.now()
                                      .subtract(Duration(days: 7)))
                              .snapshots(),
                          builder: (context, pengeluaranSnapshot) {
                            if (pengeluaranSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            double totalPengeluaran = 0;
                            if (pengeluaranSnapshot.hasData) {
                              totalPengeluaran =
                                  pengeluaranSnapshot.data!.docs.fold(
                                0.0,
                                (sum, doc) =>
                                    sum + (doc['hargaBarang'] as double),
                              );
                            }

                            double sisaPendapatan =
                                totalPendapatan - totalPengeluaran;

                            return _buildSummaryCard(
                              context,
                              'Sisa Pendapatan Minggu Ini',
                              sisaPendapatan,
                              Colors.orange,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build summary cards
  Widget _buildSummaryCard(
      BuildContext context, String title, double amount, Color color) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        tileColor: color.withOpacity(0.1),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        trailing: Text(
          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(amount),
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
