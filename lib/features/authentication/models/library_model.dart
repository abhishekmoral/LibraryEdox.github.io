import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryModel {
  final String id;
  final String libraryName;
  final String ownerName;
  final String email;
  final String mobile;
  final String address;
  final String logo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LibraryModel({
    required this.id,
    required this.libraryName,
    required this.ownerName,
    required this.email,
    required this.mobile,
    required this.address,
    required this.logo,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create an empty [LibraryModel] with default values.
  static LibraryModel empty() => LibraryModel(
        id: '',
        libraryName: '',
        ownerName: '',
        email: '',
        mobile: '',
        address: '',
        logo: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  /// Create a [LibraryModel] from a Firestore document snapshot.
  factory LibraryModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return LibraryModel(
      id: document.id,
      libraryName: data?['libraryName'] ?? '',
      ownerName: data?['ownerName'] ?? '',
      email: data?['email'] ?? '',
      mobile: data?['mobile'] ?? '',
      address: data?['address'] ?? '',
      logo: data?['logo'] ?? '',
      createdAt:
          (data?['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:
          (data?['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert the [LibraryModel] to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
        'libraryName': libraryName,
        'ownerName': ownerName,
        'email': email,
        'mobile': mobile,
        'address': address,
        'logo': logo,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  /// Create a copy of this [LibraryModel] with the given fields replaced.
  LibraryModel copyWith({
    String? id,
    String? libraryName,
    String? ownerName,
    String? email,
    String? mobile,
    String? address,
    String? logo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LibraryModel(
      id: id ?? this.id,
      libraryName: libraryName ?? this.libraryName,
      ownerName: ownerName ?? this.ownerName,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      logo: logo ?? this.logo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
