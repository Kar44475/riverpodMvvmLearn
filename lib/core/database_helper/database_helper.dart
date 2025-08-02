// import 'dart:async';
// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:learning/features/home_screen/model/product_model.dart';

// class DatabaseHelper {
//   static final DatabaseHelper _instance = DatabaseHelper._internal();
//   static Database? _database;

//   DatabaseHelper._internal();

//   factory DatabaseHelper() => _instance;

//   Future<Database> get database async {
//     _database ??= await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     String path = join(await getDatabasesPath(), 'products.db');
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createTables,
//     );
//   }

//   Future<void> _createTables(Database db, int version) async {
//     // Create products table
//     await db.execute('''
//       CREATE TABLE products (
//         id INTEGER PRIMARY KEY,
//         title TEXT,
//         price REAL,
//         description TEXT,
//         category TEXT,
//         image TEXT,
//         rating_rate REAL,
//         rating_count INTEGER
//       )
//     ''');
//   }

//   // Insert products
//   Future<void> insertProducts(List<Product> products) async {
//     final db = await database;
//     final batch = db.batch();

//     for (Product product in products) {
//       batch.insert(
//         'products',
//         {
//           'id': product.id,
//           'title': product.title,
//           'price': product.price,
//           'description': product.description,
//           'category': product.category,
//           'image': product.image,
//           'rating_rate': product.rating?.rate,
//           'rating_count': product.rating?.count,
//         },
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//     }

//     await batch.commit();
//   }

//   // Get all products
//   Future<List<Product>> getAllProducts() async {
//     final db = await database;
//     final List<Map<String, dynamic>> maps = await db.query('products');

//     return List.generate(maps.length, (i) {
//       return Product(
//         id: maps[i]['id'],
//         title: maps[i]['title'],
//         price: maps[i]['price']?.toDouble(),
//         description: maps[i]['description'],
//         category: maps[i]['category'],
//         image: maps[i]['image'],
//         rating: maps[i]['rating_rate'] != null && maps[i]['rating_count'] != null
//             ? Rating(
//                 rate: maps[i]['rating_rate'].toDouble(),
//                 count: maps[i]['rating_count'],
//               )
//             : null,
//       );
//     });
//   }

//   // Get products with pagination
//   Future<List<Product>> getProductsPaginated(int page, {int limit = 10}) async {
//     final db = await database;
//     final offset = (page - 1) * limit;
    
//     final List<Map<String, dynamic>> maps = await db.query(
//       'products',
//       limit: limit,
//       offset: offset,
//     );

//     return List.generate(maps.length, (i) {
//       return Product(
//         id: maps[i]['id'],
//         title: maps[i]['title'],
//         price: maps[i]['price']?.toDouble(),
//         description: maps[i]['description'],
//         category: maps[i]['category'],
//         image: maps[i]['image'],
//         rating: maps[i]['rating_rate'] != null && maps[i]['rating_count'] != null
//             ? Rating(
//                 rate: maps[i]['rating_rate'].toDouble(),
//                 count: maps[i]['rating_count'],
//               )
//             : null,
//       );
//     });
//   }

//   // Get total count
//   Future<int> getProductCount() async {
//     final db = await database;
//     final count = Sqflite.firstIntValue(
//       await db.rawQuery('SELECT COUNT(*) FROM products'),
//     );
//     return count ?? 0;
//   }

//   // Check if database has data
//   Future<bool> hasData() async {
//     final count = await getProductCount();
//     return count > 0;
//   }

//   // Clear all products
//   Future<void> clearProducts() async {
//     final db = await database;
//     await db.delete('products');
//   }

//   // Close database
//   Future<void> close() async {
//     final db = await database;
//     await db.close();
//     _database = null;
//   }
// }