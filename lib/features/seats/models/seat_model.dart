import 'package:cloud_firestore/cloud_firestore.dart';

class SeatModel {
  final String id;
  final String seatNumber;
  final String status;
  final String memberId;
  final String memberName;
  final String memberMobile;
  final DateTime? memberExpiry;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SeatModel({
    required this.id,
    required this.seatNumber,
    required this.status,
    required this.memberId,
    required this.memberName,
    required this.memberMobile,
    this.memberExpiry,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether the seat is available.
  bool get isAvailable => status == 'available';

  /// Whether the seat is occupied.
  bool get isOccupied => status == 'occupied';

  /// Whether the assigned member's membership is expiring within 7 days.
  bool get isExpiringSoon {
    if (memberExpiry == null) return false;
    final now = DateTime.now();
    return memberExpiry!.isAfter(now) &&
        memberExpiry!.difference(now).inDays <= 7;
  }

  /// Create an empty [SeatModel] with default values.
  static SeatModel empty() => SeatModel(
        id: '',
        seatNumber: '',
        status: 'available',
        memberId: '',
        memberName: '',
        memberMobile: '',
        memberExpiry: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Create a [SeatModel] from a Firestore document snapshot.
  factory SeatModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return SeatModel(
      id: document.id,
      seatNumber: data?['seatNumber'] ?? '',
      status: data?['status'] ?? 'available',
      memberId: data?['memberId'] ?? '',
      memberName: data?['memberName'] ?? '',
      memberMobile: data?['memberMobile'] ?? '',
      memberExpiry:
          (data?['memberExpiry'] as Timestamp?)?.toDate(),
      createdAt:
          (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data?['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert the [SeatModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
        'seatNumber': seatNumber,
        'status': status,
        'memberId': memberId,
        'memberName': memberName,
        'memberMobile': memberMobile,
        'memberExpiry':
            memberExpiry != null ? Timestamp.fromDate(memberExpiry!) : null,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  /// Create a copy of this [SeatModel] with the given fields replaced.
  SeatModel copyWith({
    String? id,
    String? seatNumber,
    String? status,
    String? memberId,
    String? memberName,
    String? memberMobile,
    DateTime? memberExpiry,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SeatModel(
      id: id ?? this.id,
      seatNumber: seatNumber ?? this.seatNumber,
      status: status ?? this.status,
      memberId: memberId ?? this.memberId,
      memberName: memberName ?? this.memberName,
      memberMobile: memberMobile ?? this.memberMobile,
      memberExpiry: memberExpiry ?? this.memberExpiry,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
