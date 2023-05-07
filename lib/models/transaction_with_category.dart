import 'package:Expense_Recorder/models/database.dart';
import 'package:flutter/foundation.dart';

class TransactionWithCategory {
  final Transaction transaction;
  final Category category;
  TransactionWithCategory(this.transaction, this.category);
}
