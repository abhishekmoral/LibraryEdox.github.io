import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationLogModel {
  final String id;
  final String memberId;
  final String memberName;
  final String type;
  final String channel;
  final String message;
  final String status;
  final DateTime? sentAt;
  final DateTime createdAt;

  const NotificationLogModel({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.type,
    required this.channel,
    required this.message,
    required this.status,
    this.sentAt,
    required this.createdAt,
  });

  /// Create an empty [NotificationLogModel] with default values.
  static NotificationLogModel empty() => NotificationLogModel(
        id: '',
        memberId: '',
        memberName: '',
        type: 'expiryReminder',
        channel: 'whatsapp',
        message: '',
        status: 'pending',
        sentAt: null,
        createdAt: DateTime.now(),
      );

  /// Create a [NotificationLogModel] from a Firestore document snapshot.
  factory NotificationLogModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return NotificationLogModel(
      id: document.id,
      memberId: data?['memberId'] ?? '',
      memberName: data?['memberName'] ?? '',
      type: data?['type'] ?? 'expiryReminder',
      channel: data?['channel'] ?? 'whatsapp',
      message: data?['message'] ?? '',
      status: data?['status'] ?? 'pending',
      sentAt: (data?['sentAt'] as Timestamp?)?.toDate(),
      createdAt:
          (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert the [NotificationLogModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
        'memberId': memberId,
        'memberName': memberName,
        'type': type,
        'channel': channel,
        'message': message,
        'status': status,
        'sentAt': sentAt != null ? Timestamp.fromDate(sentAt!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  /// Create a copy of this [NotificationLogModel] with the given fields replaced.
  NotificationLogModel copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? type,
    String? channel,
    String? message,
    String? status,
    DateTime? sentAt,
    DateTime? createdAt,
  }) {
    return NotificationLogModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      type: type ?? this.type,
      channel: channel ?? this.channel,
      message: message ?? this.message,
      status: status ?? this.status,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
