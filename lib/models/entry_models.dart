// lib/models/entry_model.dart

class Entry {
  int? id;
  String title;
  double amount;
  String date;
  int userId;
  bool isIncome; // New field to indicate whether it's income or expense

  Entry({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.userId,
    required this.isIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'date': date,
      'userId': userId,
      'isIncome': isIncome ? 1 : 0, // Store as integer (1 for income, 0 for expense)
    };
  }

  factory Entry.fromMap(Map<String, dynamic> map) {
    return Entry(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      date: map['date'],
      userId: map['userId'],
      isIncome: map['isIncome'] == 1, // Convert integer to boolean
    );
  }
}
