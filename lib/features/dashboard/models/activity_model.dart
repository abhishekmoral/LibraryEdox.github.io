import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final String? memberId;
  final String slotId;
  final DateTime createdAt;

  const ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.memberId,
    this.slotId = 'default',
    required this.createdAt,
  });

  /// Create an empty [ActivityModel] with default values.
  static ActivityModel empty() => ActivityModel(
        id: '',
        type: '',
        title: '',
        description: '',
        memberId: null,
        slotId: 'default',
        createdAt: DateTime.now(),
      );

  /// Create an [ActivityModel] from a Firestore document snapshot.
  factory ActivityModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return ActivityModel(
      id: document.id,
      type: data?['type'] ?? '',
      title: data?['title'] ?? '',
      description: data?['description'] ?? '',
      memberId: data?['memberId'],
      slotId: data?['slotId'] ?? 'default',
      createdAt:
          (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert the [ActivityModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'description': description,
        'memberId': memberId,
        'slotId': slotId,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  /// Create a copy of this [ActivityModel] with the given fields replaced.
  ActivityModel copyWith({
    String? id,
    String? type,
    String? title,
    String? description,
    String? memberId,
    String? slotId,
    DateTime? createdAt,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      memberId: memberId ?? this.memberId,
      slotId: slotId ?? this.slotId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
