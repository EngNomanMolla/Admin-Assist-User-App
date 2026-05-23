class WealthCategory {
  final String id;
  final String name;

  WealthCategory({required this.id, required this.name});

  factory WealthCategory.fromMap(Map<String, dynamic> map) {
    return WealthCategory(
      id: map['id']?.toString() ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class WealthUpdate {
  final String id;
  final double amount;
  final DateTime date;

  WealthUpdate({required this.id, required this.amount, required this.date});

  factory WealthUpdate.fromMap(Map<String, dynamic> map) {
    return WealthUpdate(
      id: map['id']?.toString() ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      date: map['date'] != null 
          ? DateTime.parse(map['date']) 
          : (map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}

class WealthTransaction {
  final String id;
  final String title;
  final double amount; // Original amount
  final String categoryId;
  final DateTime date;
  final List<WealthUpdate> updates;
  final String notes;

  WealthTransaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.updates = const [],
    this.notes = '',
  });

  factory WealthTransaction.fromMap(Map<String, dynamic> map) {
    var updatesList = <WealthUpdate>[];
    if (map['updates'] != null) {
      updatesList = (map['updates'] as List)
          .map((e) => WealthUpdate.fromMap(e))
          .toList();
    } else if (map['records'] != null) {
      updatesList = (map['records'] as List)
          .map((e) => WealthUpdate.fromMap(e))
          .toList();
    }
    return WealthTransaction(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      categoryId: map['asset_category_id']?.toString() ?? map['category_id']?.toString() ?? '',
      date: map['transaction_date'] != null 
          ? DateTime.parse(map['transaction_date']) 
          : (map['date'] != null 
              ? DateTime.parse(map['date']) 
              : (map['created_at'] != null ? DateTime.parse(map['created_at']) : DateTime.now())),
      updates: updatesList,
      notes: map['notes'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'asset_category_id': categoryId,
      'transaction_date': date.toIso8601String(),
      'notes': notes,
      'updates': updates.map((e) => e.toMap()).toList(),
    };
  }

  double get totalAmount {
    return amount + updates.fold(0.0, (sum, u) => sum + u.amount);
  }
}
