import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandlerSearch {
  // select
  Future<Database> initializeDB() async{
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'search.db'),
      onCreate: (db, version) async{
        await db.execute(
          """
          create table search (
          id integer primary key autoincrement,
          customer_id int,
          context text
          )
          """
        );
      },
      version: 1,
    );
  }

  Future<List<String>> querySearch(int id) async{
    final Database db = await initializeDB();
    final List<Map<String, Object?>> queryResults = await db. rawQuery(
      'select * from search where customer_id = ? order by id desc limit 4',
      [id]
    );
    return queryResults.map((e) => e['context'] as String).toList();
  }

  // insert
  Future<int> insertSearch(int id, String context) async{
    int result = 0;
    final Database db = await initializeDB();
    result = await db.rawInsert(
      """
      insert into search
      (customer_id, context)
      values
      (?,?)
      """,
      [id,context]
    );
    print("Insert Return Value : $result");

    return result;
  }

  // delete
  Future<void> deleteSearch(int id, String context) async{
    final Database db = await initializeDB();
    await db.rawUpdate(
      """
      delete from search
      where customer_id = ?
      and context = ?
      """,
      [id,context]
    );
  }



}