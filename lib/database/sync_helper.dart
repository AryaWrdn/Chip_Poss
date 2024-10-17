import 'package:chip_pos/database/product.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'db_helper.dart';

Future<bool> isConnected() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
}

Future<void> syncDataToFirebase(DatabaseHelper dbHelper) async {
  if (await isConnected()) {
    try {
      List<Product> localProducts = await dbHelper.getProducts();
      for (var product in localProducts) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(product.id.toString())
            .set({
          'name': product.name,
          'price': product.price,
          'stock': product.stock,
          'imageUrl': product.imageUrl,
        });
      }
      print('Data successfully synced to Firebase');
    } catch (e) {
      print('Error syncing data to Firebase: $e');
    }
  } else {
    print('No internet connection. Unable to sync data.');
  }
}
