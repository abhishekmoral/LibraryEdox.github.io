import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentModel {
  final String id;
  final String memberId;
  final String memberName;
  final double amount;
  final DateTime date;
  final String paymentMethod;
  final String planId;
  final String planName;
  final String type;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.planId,
    required this.planName,
    required this.type,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create an empty [PaymentModel] with default values.
  static PaymentModel empty() => PaymentModel(
        id: '',
        memberId: '',
        memberName: '',
        amount: 0.0,
        date: DateTime.now(),
        paymentMethod: 'cash',
        planId: '',
        planName: '',
        type: 'new',
        notes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Create a [PaymentModel] from a Firestore document snapshot.
  factory PaymentModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return PaymentModel(
      id: document.id,
      memberId: data?['memberId'] ?? '',
      memberName: data?['memberName'] ?? '',
      amount: (data?['amount'] ?? 0.0).toDouble(),
      date: (data?['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentMethod: data?['paymentMethod'] ?? 'cash',
      planId: data?['planId'] ?? '',
      planName: data?['planName'] ?? '',
      type: data?['type'] ?? 'new',
      notes: data?['notes'] ?? '',
      createdAt:
          (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data?['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert the [PaymentModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'memberName': memberName,
        'amount': amount,
        'date': Timestamp.fromDate(date),
        'paymentMethod': paymentMethod,
        'planId': planId,
        'planName': planName,
        'type': type,
        'notes': notes,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  /// Create a copy of this [PaymentModel] with the given fields replaced.
  PaymentModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    double? amount,
    DateTime? date,
    String? paymentMethod,
    String? planId,
    String? planName,
    String? type,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      type: type ?? this.type,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
