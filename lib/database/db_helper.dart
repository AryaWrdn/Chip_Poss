import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'product.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'products.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            price REAL,
            stock INTEGER,
            imageUrl TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE products ADD COLUMN imageUrl TEXT;');
        }
      },
    );
  }

  Future<void> insertOrUpdateProduct(Product product) async {
    final db = await database;
    // Check if the product already exists
    var existingProduct = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [product.id],
    );

    if (existingProduct.isNotEmpty) {
      // If exists, update the product
      await db.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    } else {
      // If not, insert the product
      await db.insert(
        'products',
        product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        name: maps[i]['name'],
        price: maps[i]['price'],
        stock: maps[i]['stock'],
        imageUrl: maps[i]['imageUrl'],
      );
    });
  }

  Future<void> updateProduct(Product product) async {
    final db = await database;
    await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteProduct(int id) async {
    final db = await database;
    await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );

    await FirebaseFirestore.instance
        .collection('products')
        .doc(id.toString())
        .delete();
  }

  Future<void> syncDataToFirebase() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      try {
        List<Product> localProducts = await getProducts();
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
}
