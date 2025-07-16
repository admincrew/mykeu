class Income {
  final int? id;
  final String description;
  final int amount;
  final String date;

  Income({
    this.id,
    required this.description,
    required this.amount,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'amount': amount,
      'date': date,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      description: map['description'],
      amount: map['amount'],
      date: map['date'],
    );
  }
}
