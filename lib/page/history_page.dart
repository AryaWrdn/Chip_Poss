import 'dart:io';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:chip_pos/page/order_page.dart';
import 'package:chip_pos/styles/stylbttn.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:chip_pos/styles/style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:chip_pos/page/layoutprint/printenum.dart';

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  TextEditingController _searchController = TextEditingController();
  final BlueThermalPrinter printer = BlueThermalPrinter.instance;
  bool _connected = false;
  BluetoothDevice? _device;
  List<BluetoothDevice> _devices = [];

  String _searchQuery = '';

  @override
  void initState() {
    initPlatformState();
    super.initState();
  }

  void _connect() {
    if (_device != null) {
      printer.connect(_device!).catchError((error) {});
      setState(() => _connected = true);
      printLayout();
      // printer.isConnected.then((isConnected) {
      //   if (isConnected == true) {
      //     print("Already connected to ${_device!.name}");
      //   }
      // });
    }
  }

  void printLayout() async {
    // String filename = 'catatan.png';
    // ByteData bytesData = await rootBundle.load("assets/images/catatan.png");
    // String dir = (await getApplicationDocumentsDirectory()).path;
    // File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
    //     .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

    ///image from Asset
    // ByteData bytesAsset = await rootBundle.load("assets/images/catatan.png");
    // Uint8List imageBytesFromAsset = bytesAsset.buffer
    //     .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    // ///image from Network
    // var response = await http.get(Uri.parse(
    //     "https://raw.githubusercontent.com/kakzaki/blue_thermal_printer/master/example/assets/images/yourlogo.png"));
    // Uint8List bytesNetwork = response.bodyBytes;
    // // Uint8List imageBytesFromNetwork = bytesNetwork.buffer
    //     .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);
    printer.printNewLine();
    printer.printCustom("HEADER", Size.boldMedium.val, AlignLayout.center.val);
    printer.printNewLine();
    // printer.printImage(file.path); //path of your image/logo
    printer.printNewLine();
    // printer.printImageBytes(imageBytesFromAsset); //image from Asset
    printer.printNewLine();
    // printer.printImageBytes(imageBytesFromNetwork); //image from Network
    printer.printNewLine();
    printer.printLeftRight("LEFT", "RIGHT", Size.medium.val);
    printer.printLeftRight("LEFT", "RIGHT", Size.bold.val);
    printer.printLeftRight("LEFT", "RIGHT", Size.bold.val,
        format:
            "%-15s %15s %n"); //15 is number off character from left or right
    printer.printNewLine();
    printer.printLeftRight("LEFT", "RIGHT", Size.boldMedium.val);
    printer.printLeftRight("LEFT", "RIGHT", Size.boldLarge.val);
    printer.printLeftRight("LEFT", "RIGHT", Size.extraLarge.val);
    printer.printNewLine();
    printer.print3Column("Col1", "Col2", "Col3", Size.bold.val);
    printer.print3Column("Col1", "Col2", "Col3", Size.bold.val,
        format:
            "%-10s %10s %10s %n"); //10 is number off character from left center and right
    printer.printNewLine();
    printer.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val);
    printer.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val,
        format: "%-8s %7s %7s %7s %n");
    printer.printNewLine();
    printer.printCustom("čĆžŽšŠ-H-ščđ", Size.bold.val, AlignLayout.center.val,
        charset: "windows-1250");
    printer.printLeftRight("Številka:", "18000001", Size.bold.val,
        charset: "windows-1250");
    printer.printCustom("Body left", Size.bold.val, AlignLayout.left.val);
    printer.printCustom("Body right", Size.medium.val, AlignLayout.right.val);
    printer.printNewLine();
    printer.printCustom("Thank You", Size.bold.val, AlignLayout.center.val);
    printer.printNewLine();
    printer.printQRcode(
        "Insert Your Own Text to Generate", 200, 200, AlignLayout.center.val);
    printer.printNewLine();
    printer.printNewLine();
    printer.paperCut();
  }

  Future<void> initPlatformState() async {
    bool? isConnected = await printer.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await printer.getBondedDevices();
      setState(() {
        _device = devices[3];
      });
    } on PlatformException {}

    printer.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          setState(() {
            _connected = true;
            print("bluetooth device state: connected");
          });
          break;
        case BlueThermalPrinter.DISCONNECTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnected");
          });
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          setState(() {
            _connected = false;
            print("bluetooth device state: disconnect requested");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning off");
          });
          break;
        case BlueThermalPrinter.STATE_OFF:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth off");
          });
          break;
        case BlueThermalPrinter.STATE_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth on");
          });
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          setState(() {
            _connected = false;
            print("bluetooth device state: bluetooth turning on");
          });
          break;
        case BlueThermalPrinter.ERROR:
          setState(() {
            _connected = false;
            print("bluetooth device state: error");
          });
          break;
        default:
          print(state);
          break;
      }
    });

    if (!mounted) return;
    setState(() {
      _devices = devices;
    });

    if (isConnected == true) {
      setState(() {
        _connected = true;
      });
    }
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
                                        Container(
                                          height: 40,
                                          child: Bttnstyl(
                                            child: ElevatedButton(
                                              style: raisedButtonStyle,
                                              onPressed: () {
                                                _connect();
                                              },
                                              child: SizedBox(
                                                width: 120,
                                                child: Text(
                                                  'Print Order History',
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
