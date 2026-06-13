import 'package:uuid/uuid.dart';

class TransactionModel {
  final String id; // Unique ID for each transaction
  final DateTime date;
  final String description;
  final String type; // 'Pemasukan' or 'Pengeluaran'
  final num amount;

  TransactionModel({
    String? id, // Make id optional for new transactions
    required this.date,
    required this.description,
    required this.type,
    required this.amount,
  }) : id = id ?? Uuid().v4(); // Generate UUID if not provided

  // For converting to/from JSON (SharedPreferences)
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'description': description,
        'type': type,
        'amount': amount,
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        id: json['id'],
        date: DateTime.parse(json['date']),
        description: json['description'],
        type: json['type'],
        amount: json['amount'],
      );
}