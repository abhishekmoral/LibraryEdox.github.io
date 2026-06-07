class DashboardStatsModel {
  final int totalMembers;
  final int activeMembers;
  final int expiredMembers;
  final int expiringSoon;
  final int totalSeats;
  final int availableSeats;
  final int occupiedSeats;
  final int pendingPayments;
  final double monthlyRevenue;
  final double todaysCollection;

  const DashboardStatsModel({
    required this.totalMembers,
    required this.activeMembers,
    required this.expiredMembers,
    required this.expiringSoon,
    required this.totalSeats,
    required this.availableSeats,
    required this.occupiedSeats,
    required this.pendingPayments,
    required this.monthlyRevenue,
    required this.todaysCollection,
  });

  /// Create an empty [DashboardStatsModel] with zeroed values.
  static DashboardStatsModel empty() => const DashboardStatsModel(
        totalMembers: 0,
        activeMembers: 0,
        expiredMembers: 0,
        expiringSoon: 0,
        totalSeats: 0,
        availableSeats: 0,
        occupiedSeats: 0,
        pendingPayments: 0,
        monthlyRevenue: 0.0,
        todaysCollection: 0.0,
      );

  /// Create a [DashboardStatsModel] from a JSON map.
  factory DashboardStatsModel.fromJson(Map<String, dynamic> data) {
    return DashboardStatsModel(
      totalMembers: data['totalMembers'] ?? 0,
      activeMembers: data['activeMembers'] ?? 0,
      expiredMembers: data['expiredMembers'] ?? 0,
      expiringSoon: data['expiringSoon'] ?? 0,
      totalSeats: data['totalSeats'] ?? 0,
      availableSeats: data['availableSeats'] ?? 0,
      occupiedSeats: data['occupiedSeats'] ?? 0,
      pendingPayments: data['pendingPayments'] ?? 0,
      monthlyRevenue: (data['monthlyRevenue'] ?? 0.0).toDouble(),
      todaysCollection: (data['todaysCollection'] ?? 0.0).toDouble(),
    );
  }

  /// Convert the [DashboardStatsModel] to a JSON map.
  Map<String, dynamic> toJson() => {
        'totalMembers': totalMembers,
        'activeMembers': activeMembers,
        'expiredMembers': expiredMembers,
        'expiringSoon': expiringSoon,
        'totalSeats': totalSeats,
        'availableSeats': availableSeats,
        'occupiedSeats': occupiedSeats,
        'pendingPayments': pendingPayments,
        'monthlyRevenue': monthlyRevenue,
        'todaysCollection': todaysCollection,
      };

  /// Create a copy of this [DashboardStatsModel] with the given fields replaced.
  DashboardStatsModel copyWith({
    int? totalMembers,
    int? activeMembers,
    int? expiredMembers,
    int? expiringSoon,
    int? totalSeats,
    int? availableSeats,
    int? occupiedSeats,
    int? pendingPayments,
    double? monthlyRevenue,
    double? todaysCollection,
  }) {
    return DashboardStatsModel(
      totalMembers: totalMembers ?? this.totalMembers,
      activeMembers: activeMembers ?? this.activeMembers,
      expiredMembers: expiredMembers ?? this.expiredMembers,
      expiringSoon: expiringSoon ?? this.expiringSoon,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      occupiedSeats: occupiedSeats ?? this.occupiedSeats,
      pendingPayments: pendingPayments ?? this.pendingPayments,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      todaysCollection: todaysCollection ?? this.todaysCollection,
    );
  }
}
