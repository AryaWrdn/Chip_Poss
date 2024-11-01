import 'dart:async';
import 'package:chip_pos/page/history_page.dart';
import 'package:chip_pos/page/order_page.dart';
import 'package:chip_pos/page/product_page.dart';
import 'package:chip_pos/page/stock.dart';
import 'package:chip_pos/styles/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:fl_chart/fl_chart.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;
  double totalPendapatan = 0; // Total revenue

  @override
  void initState() {
    super.initState();
    _fetchTotalPendapatan(); // Fetch the total revenue at the start

    _timer = Timer.periodic(const Duration(seconds: 7), (Timer timer) {
      if (_currentPage < 2) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      // Scroll to the next page automatically
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeIn,
      );
    });

    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  Future<void> _fetchTotalPendapatan() async {
    // Fetch total revenue from Firestore
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('orderHistory').get();

    double total = 0;
    for (var order in snapshot.docs) {
      var orderData = order.data() as Map<String, dynamic>;
      total += orderData['total'];
    }

    setState(() {
      totalPendapatan = total; // Update the state with the total revenue
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Hentikan timer saat widget di-dispose
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: 785,
          child: Stack(
            children: [
              Container(
                height: 785,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(154, 203, 200, 185),
                ),
              ),
              Container(
                height: 453,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(255, 180, 181, 168), // Warna solid di atas
                      Color.fromARGB(0, 138, 141,
                          99), // Warna yang lebih transparan di bawah
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
              Container(
                height: 305,
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
                height: 300,
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
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 81, 81, 54),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextField(
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
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                          radius: 25.0,
                          backgroundImage: AssetImage('assets/images/1.jpeg')
                          // NetworkImage(
                          //     'https://example.com/1.jpeg'),
                          ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Container(
                    height: 150,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
                    child: Container(
                      height:
                          60, // Meninggikan container untuk memberi ruang bagi elemen
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors
                              .abuabuabu, // Ganti dengan warna yang diinginkan
                          width: 2, // Ganti dengan ketebalan yang diinginkan
                        ),
                        color: const Color.fromARGB(189, 248, 242, 221),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('orderHistory')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          double total = 0;
                          for (var order in snapshot.data!.docs) {
                            var orderData =
                                order.data() as Map<String, dynamic>;
                            total += orderData['total'];
                          }

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Pendapatan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 80),
                                  Icon(
                                    Icons.arrow_upward,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  SizedBox(width: 16),
                                  Text(
                                    NumberFormat.currency(
                                            locale: 'id_ID', symbol: 'Rp ')
                                        .format(total),
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: SizedBox(
                      height: 150,
                      child: PageView(
                        controller: _pageController,
                        children: [
                          imageCard(
                              'https://www.sasa.co.id/medias/page_medias/Screen_Shot_2021-10-12_at_09_28_42.png'),
                          imageCard(
                              'https://www.blibli.com/friends-backend/wp-content/uploads/2023/08/COVER.jpg'),
                          imageCard(
                              'https://asset-2.tstatic.net/medan/foto/bank/images/burger-enak-di-medan.jpg'),
                        ],
                      ),
                    ),
                  ),

                  // Indikator titik
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.kuning // Warna aktif
                              : AppColors.background, // Warna tidak aktif
                        ),
                      );
                    }),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child:
                        const Divider(color: AppColors.abuabuabu, thickness: 2),
                  ),

                  // Menu 3 kotak di tengah secara horizontal
                  Container(
                    height: 370,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              menuBox(
                                'Tambah Menu',
                                Image.asset('assets/images/hi.webp',
                                    height: 60,
                                    width:
                                        60), // Ganti dengan path gambar yang sesuai
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductPage()),
                                ),
                              ),
                              menuBox(
                                'Catat Pesanan',
                                Image.asset('assets/images/catatan.png',
                                    height: 54,
                                    width:
                                        54), // Ganti dengan path gambar yang sesuai
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrderPage()),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              menuBox(
                                'History Pesanan',
                                Image.asset('assets/images/history.png',
                                    height: 54,
                                    width:
                                        54), // Ganti dengan path gambar yang sesuai
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HistoryPage()),
                                ),
                              ),
                              menuBox(
                                'Stock Product',
                                Image.asset('assets/images/stock.png',
                                    height: 54,
                                    width:
                                        54), // Ganti dengan path gambar yang sesuai
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StockPage()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tampilan Statistik (contoh diagram)
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageCard(String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: imagePath.startsWith('http')
                ? NetworkImage(imagePath)
                : AssetImage(imagePath) as ImageProvider,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget menuBox(String title, Widget icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          color: const Color.fromARGB(189, 248, 242, 221),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
              blurRadius: 3,
              spreadRadius: 2,
              offset: const Offset(0, 3), // bayangan ke bawah
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon, // Gambar atau ikon sebagai widget
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.hitamgelap,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
