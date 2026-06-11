import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id;
  final String fullName;
  final String mobile;
  final String alternateMobile;
  final String email;
  final String address;
  final String gender;
  final String photo;
  final String seatId;
  final String seatNumber;
  final String slotId;
  final DateTime joiningDate;
  final String planId;
  final String planName;
  final DateTime expiryDate;
  final String paymentStatus;
  final String status;
  final String notes;
  final DateTime? deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MemberModel({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.alternateMobile,
    required this.email,
    required this.address,
    required this.gender,
    required this.photo,
    required this.seatId,
    required this.seatNumber,
    required this.slotId,
    required this.joiningDate,
    required this.planId,
    required this.planName,
    required this.expiryDate,
    required this.paymentStatus,
    required this.status,
    required this.notes,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Number of days remaining until expiry. Returns 0 if already expired.
  int get daysRemaining {
    final remaining = expiryDate.difference(DateTime.now()).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  /// Whether the membership has expired.
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// Whether the membership is expiring within 7 days.
  bool get isExpiringSoon =>
      !isExpired && expiryDate.difference(DateTime.now()).inDays <= 7;

  /// Create an empty [MemberModel] with default values.
  static MemberModel empty() => MemberModel(
        id: '',
        fullName: '',
        mobile: '',
        alternateMobile: '',
        email: '',
        address: '',
        gender: '',
        photo: '',
        seatId: '',
        seatNumber: '',
        slotId: 'default',
        joiningDate: DateTime.now(),
        planId: '',
        planName: '',
        expiryDate: DateTime.now(),
        paymentStatus: 'pending',
        status: 'active',
        notes: '',
        deletedAt: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Create a [MemberModel] from a Firestore document snapshot.
  factory MemberModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return MemberModel(
      id: document.id,
      fullName: data?['fullName'] ?? '',
      mobile: data?['mobile'] ?? '',
      alternateMobile: data?['alternateMobile'] ?? '',
      email: data?['email'] ?? '',
      address: data?['address'] ?? '',
      gender: data?['gender'] ?? '',
      photo: data?['photo'] ?? '',
      seatId: data?['seatId'] ?? '',
      seatNumber: data?['seatNumber'] ?? '',
      slotId: data?['slotId'] ?? 'default',
      joiningDate:
          (data?['joiningDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      planId: data?['planId'] ?? '',
      planName: data?['planName'] ?? '',
      expiryDate:
          (data?['expiryDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      paymentStatus: data?['paymentStatus'] ?? 'pending',
      status: data?['status'] ?? 'active',
      notes: data?['notes'] ?? '',
      deletedAt: (data?['deletedAt'] as Timestamp?)?.toDate(),
      createdAt:
          (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data?['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert the [MemberModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'mobile': mobile,
        'alternateMobile': alternateMobile,
        'email': email,
        'address': address,
        'gender': gender,
        'photo': photo,
        'seatId': seatId,
        'seatNumber': seatNumber,
        'slotId': slotId,
        'joiningDate': Timestamp.fromDate(joiningDate),
        'planId': planId,
        'planName': planName,
        'expiryDate': Timestamp.fromDate(expiryDate),
        'paymentStatus': paymentStatus,
        'status': status,
        'notes': notes,
        if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  /// Create a copy of this [MemberModel] with the given fields replaced.
  MemberModel copyWith({
    String? id,
    String? fullName,
    String? mobile,
    String? alternateMobile,
    String? email,
    String? address,
    String? gender,
    String? photo,
    String? seatId,
    String? seatNumber,
    String? slotId,
    DateTime? joiningDate,
    String? planId,
    String? planName,
    DateTime? expiryDate,
    String? paymentStatus,
    String? status,
    String? notes,
    DateTime? deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemberModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      alternateMobile: alternateMobile ?? this.alternateMobile,
      email: email ?? this.email,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      photo: photo ?? this.photo,
      seatId: seatId ?? this.seatId,
      seatNumber: seatNumber ?? this.seatNumber,
      slotId: slotId ?? this.slotId,
      joiningDate: joiningDate ?? this.joiningDate,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      expiryDate: expiryDate ?? this.expiryDate,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
