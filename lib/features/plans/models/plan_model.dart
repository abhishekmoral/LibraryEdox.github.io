import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  final String id;
  final String planName;
  final int duration;
  final double price;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlanModel({
    required this.id,
    required this.planName,
    required this.duration,
    required this.price,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Human-readable duration text (e.g., '1 Month', '3 Months').
  String get durationText =>
      duration == 1 ? '$duration Month' : '$duration Months';

  /// Create an empty [PlanModel] with default values.
  static PlanModel empty() => PlanModel(
        id: '',
        planName: '',
        duration: 1,
        price: 0.0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Create a [PlanModel] from a Firestore document snapshot.
  factory PlanModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return PlanModel(
      id: document.id,
      planName: data?['planName'] ?? '',
      duration: data?['duration'] ?? 1,
      price: (data?['price'] ?? 0.0).toDouble(),
      isActive: data?['isActive'] ?? true,
      createdAt:
          (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data?['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert the [PlanModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
        'planName': planName,
        'duration': duration,
        'price': price,
        'isActive': isActive,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  /// Create a copy of this [PlanModel] with the given fields replaced.
  PlanModel copyWith({
    String? id,
    String? planName,
    int? duration,
    double? price,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlanModel(
      id: id ?? this.id,
      planName: planName ?? this.planName,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
