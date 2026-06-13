import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class StorageService {
  static const _transactionsKey = 'transactions';

  Future<List<TransactionModel>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsJson = prefs.getString(_transactionsKey);
    if (transactionsJson == null) {
      return [];
    }
    final List<dynamic> decodedList = json.decode(transactionsJson);
    return decodedList.map((json) => TransactionModel.fromJson(json)).toList();
  }

  Future<void> saveAll(List<TransactionModel> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList =
        json.encode(transactions.map((e) => e.toJson()).toList());
    await prefs.setString(_transactionsKey, encodedList);
  }

  Future<void> add(TransactionModel transaction) async {
    final allTransactions = await getAll();
    allTransactions.add(transaction);
    await saveAll(allTransactions);
  }

  Future<void> update(TransactionModel updatedTransaction) async {
    final allTransactions = await getAll();
    final index =
        allTransactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      allTransactions[index] = updatedTransaction;
      await saveAll(allTransactions);
    }
  }

  Future<void> delete(String id) async {
    final allTransactions = await getAll();
    allTransactions.removeWhere((t) => t.id == id);
    await saveAll(allTransactions);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
  }

  Future<void> removeLast() async {
    final allTransactions = await getAll();
    if (allTransactions.isNotEmpty) {
      allTransactions.removeLast();
      await saveAll(allTransactions);
    }
  }

  // Method to get a single transaction by ID (useful for editing)
  Future<TransactionModel?> getById(String id) async {
    final allTransactions = await getAll();
    return allTransactions.firstWhere(
      (t) => t.id == id,
      orElse: () => throw Exception('Transaction not found'),
    );
  }
}