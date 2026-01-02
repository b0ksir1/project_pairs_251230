// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class DatabaseHandlerSearch {
//   // select
//   Future<Database> initializeDB() async{
//     String path = await getDatabasesPath();

//     return openDatabase(
//       join(path, 'search.db'),
//       onCreate: (db, version) async{
//         await db.execute(
//           """
//           create table search (
//           id integer primary key autoincrement,
//           customer_id int,
//           context text
//           )
//           """
//         );
//       },
//       version: 1,
//     );
//   }

//   // insert
//   Future<int> insertSearch()



// }