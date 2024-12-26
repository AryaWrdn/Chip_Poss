import 'dart:async';
import 'package:chip_pos/page/catatpengeluaran.dart';
import 'package:chip_pos/page/history_page.dart';
import 'package:chip_pos/page/order_page.dart';
import 'package:chip_pos/page/product_page.dart';
import 'package:chip_pos/page/stock.dart';
import 'package:chip_pos/styles/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  List<Map<String, dynamic>> filteredProducts = [];
  List<Map<String, dynamic>> products = [];
  final PageController _pageController = PageController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  late Timer _timer;
  double totalPendapatan = 0;

  @override
  void initState() {
    super.initState();
    _fetchProductsFromFirebase();
    _fetchTotalPendapatan();
    _searchController.addListener(_filterProducts);

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

  Future<void> _fetchProductsFromFirebase() async {
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
      filteredProducts = products;
    });
  }

  void _filterProducts() {
    setState(() {
      filteredProducts = products
          .where((product) => product['name']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
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

  Future<void> _refreshPage() async {
    await _fetchProductsFromFirebase();
    await _fetchTotalPendapatan();
  }

  @override
  void dispose() {
    _timer.cancel();
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPage,
        child: SingleChildScrollView(
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
                        Color.fromARGB(
                            255, 180, 181, 168), // Warna solid di atas
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
                              suffixIcon:
                                  Icon(Icons.search, color: Colors.grey),
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
                      height: 130,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 5),
                      child: Container(
                        height:
                            40, // Meninggikan container untuk memberi ruang bagi elemen
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
                                ? AppColors.kuning
                                : AppColors.background,
                          ),
                        );
                      }),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 5, 16, 5),
                      child: Container(
                        height: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: menuBox(
                                'Tambah    Menu',
                                Image.asset(
                                  'assets/images/hi.webp',
                                  height: 29,
                                  width: 29,
                                ),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProductPage()),
                                ),
                              ),
                            ),
                            Expanded(
                              child: menuBox(
                                'Catat     Pesanan',
                                Image.asset(
                                  'assets/images/catatan.png',
                                  height: 29,
                                  width: 29,
                                ),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => OrderPage()),
                                ),
                              ),
                            ),
                            Expanded(
                              child: menuBox(
                                'History Pesanan',
                                Image.asset(
                                  'assets/images/history.png',
                                  height: 29,
                                  width: 29,
                                ),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HistoryPage()),
                                ),
                              ),
                            ),
                            Expanded(
                              child: menuBox(
                                'Stock     Product',
                                Image.asset(
                                  'assets/images/stock.png',
                                  height: 29,
                                  width: 29,
                                ),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StockPage()),
                                ),
                              ),
                            ),
                            Expanded(
                              child: menuBox(
                                'Catat Pengeluaran',
                                Image.asset(
                                  'assets/images/catat pengeluaran.png',
                                  height: 29,
                                  width: 29,
                                ),
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CatatPengeluaran(
                                          totalPendapatan: totalPendapatan)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: const Divider(
                          color: AppColors.abuabuabu, thickness: 2),
                    ),
                    Container(
                      height: 320,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                      child: ListView.builder(
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                                          ? Image.network(
                                              product['imageUrl'],
                                              fit: BoxFit.cover,
                                            )
                                          : Image.asset(
                                              'assets/images/1.jpeg',
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'],
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text('Stock: ${product['stock']}'),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Rp ${NumberFormat("#,##0", "id_ID").format(product['price'])}',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
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
                ),
              ],
            ),
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
        width: 40,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            icon, // Gambar atau ikon sebagai widget
            const SizedBox(height: 0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.hitamgelap,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
