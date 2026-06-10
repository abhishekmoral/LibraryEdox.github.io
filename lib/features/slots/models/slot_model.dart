import 'package:cloud_firestore/cloud_firestore.dart';

class SlotModel {
  final String id;
  final String name;      // e.g., "Morning"
  final String startTime; // e.g., "5:00 AM"
  final String endTime;   // e.g., "9:00 AM"
  final DateTime createdAt;
  final DateTime updatedAt;

  const SlotModel({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create an empty [SlotModel] with default values.
  static SlotModel empty() => SlotModel(
        id: '',
        name: '',
        startTime: '',
        endTime: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Create a [SlotModel] from a Firestore document snapshot.
  factory SlotModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return SlotModel(
      id: document.id,
      name: data?['name'] ?? '',
      startTime: data?['startTime'] ?? '',
      endTime: data?['endTime'] ?? '',
      createdAt:
          (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data?['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert the [SlotModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
        'name': name,
        'startTime': startTime,
        'endTime': endTime,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  /// Create a copy of this [SlotModel] with the given fields replaced.
  SlotModel copyWith({
    String? id,
    String? name,
    String? startTime,
    String? endTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SlotModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
