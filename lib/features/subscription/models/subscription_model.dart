import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String id;
  final String planName;
  final DateTime startDate;
  final DateTime expiryDate;
  final String status;
  final String billing;
  final DateTime createdAt;
  final String libraryName;
  final String mobile;

  const SubscriptionModel({
    required this.id,
    required this.planName,
    required this.startDate,
    required this.expiryDate,
    required this.status,
    required this.billing,
    required this.createdAt,
    this.libraryName = '',
    this.mobile = '',
  });

  /// Whether the subscription is currently active (not expired and status is 'active').
  bool get isActive =>
      status == 'active' && DateTime.now().isBefore(expiryDate);

  /// Number of days remaining until expiry. Returns 0 if already expired.
  int get daysRemaining {
    final remaining = expiryDate.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// Create an empty [SubscriptionModel] with default values.
  static SubscriptionModel empty() => SubscriptionModel(
        id: '',
        planName: 'trial',
        startDate: DateTime.now(),
        expiryDate: DateTime.now(),
        status: 'active',
        billing: 'monthly',
        createdAt: DateTime.now(),
        libraryName: '',
        mobile: '',
      );

  /// Create a [SubscriptionModel] from a Firestore document snapshot.
  factory SubscriptionModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return SubscriptionModel(
      id: document.id,
      planName: data?['planName'] ?? 'trial',
      startDate:
          (data?['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiryDate:
          (data?['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data?['status'] ?? 'active',
      billing: data?['billing'] ?? 'monthly',
      createdAt:
          (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      libraryName: data?['libraryName'] ?? '',
      mobile: data?['mobile'] ?? '',
    );
  }

  /// Convert the [SubscriptionModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
        'planName': planName,
        'startDate': Timestamp.fromDate(startDate),
        'expiryDate': Timestamp.fromDate(expiryDate),
        'status': status,
        'billing': billing,
        'createdAt': Timestamp.fromDate(createdAt),
        'libraryName': libraryName,
        'mobile': mobile,
      };

  /// Create a copy of this [SubscriptionModel] with the given fields replaced.
  SubscriptionModel copyWith({
    String? id,
    String? planName,
    DateTime? startDate,
    DateTime? expiryDate,
    String? status,
    String? billing,
    DateTime? createdAt,
    String? libraryName,
    String? mobile,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      planName: planName ?? this.planName,
      startDate: startDate ?? this.startDate,
      expiryDate: expiryDate ?? this.expiryDate,
      status: status ?? this.status,
      billing: billing ?? this.billing,
      createdAt: createdAt ?? this.createdAt,
      libraryName: libraryName ?? this.libraryName,
      mobile: mobile ?? this.mobile,
    );
  }
}
