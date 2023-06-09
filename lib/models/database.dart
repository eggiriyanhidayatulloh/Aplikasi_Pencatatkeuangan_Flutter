import 'dart:io';
import 'package:Expense_Recorder/models/transaction_with_category.dart';
import 'package:drift/drift.dart';
// These imports are used to open the database
import 'package:drift/native.dart';
import 'package:flutter/src/foundation/annotations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'category.dart';
import 'transaction.dart';

part 'database.g.dart';

@DriftDatabase(
    // relative import for the drift file. Drift also supports `package:`
    // imports
    tables: [Categories, Transactions])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Function CRUD

  // buat function untuk where type nya (input)
  Future<List<category>> getAllCategoryRepo(int type) async {
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
        .get();
  }

  // function untuk update
  Future updateCategroyRepo(int id, String name) async {
    return (update(categories)..where((tbl) => tbl.id.equals(id)))
        .write(CategoriesCompanion(name: Value(name)));
  }

  // function untuk delete
  Future deleteCategoryRepo(
    int id,
  ) async {
    return (delete(categories)..where((tbl) => tbl.id.equals(id))).go();
  }

  // function transaction
  // panggil type class transactioncategory, dan berinama getTransactionbydate
  Stream<List<TransactionWithCategory>> getTransactionByDateRepo(
      DateTime date) {
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ])
      ..where(transactions.transaction_date.equals(date)));

    return query.watch().map((rows) {
      return rows.map((row) {
        return TransactionWithCategory(
            row.readTable(transactions),
            row.readTable(categories
                as ResultSetImplementation<$CategoriesTable, Category>));
      }).toList();
    });
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
