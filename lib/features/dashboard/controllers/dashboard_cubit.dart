import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/seats/seat_repository.dart';
import 'package:edox_library/data/repositories/payments/payment_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/features/dashboard/models/dashboard_stats_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';

class DashboardState {
  final bool isLoading;
  final DashboardStatsModel stats;
  final List<ActivityModel> recentActivity;
  final List<double> revenueChartData;

  DashboardState({
    required this.isLoading,
    required this.stats,
    required this.recentActivity,
    required this.revenueChartData,
  });

  DashboardState copyWith({
    bool? isLoading,
    DashboardStatsModel? stats,
    List<ActivityModel>? recentActivity,
    List<double>? revenueChartData,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      recentActivity: recentActivity ?? this.recentActivity,
      revenueChartData: revenueChartData ?? this.revenueChartData,
    );
  }
}

class DashboardCubit extends Cubit<DashboardState> {
  final _memberRepo = MemberRepository.instance;
  final _seatRepo = SeatRepository.instance;
  final _paymentRepo = PaymentRepository.instance;
  final _activityRepo = ActivityRepository.instance;

  StreamSubscription<List<ActivityModel>>? _activitySubscription;
  StreamSubscription<User?>? _authSubscription;

  DashboardCubit() : super(DashboardState(
    isLoading: false,
    stats: DashboardStatsModel.empty(),
    recentActivity: [],
    revenueChartData: List.filled(6, 0.0),
  )) {
    _init();
  }

  void _init() {
    _authSubscription = AuthenticationRepository.instance.authStateChanges.listen((user) {
      if (user != null) {
        fetchDashboardData();
        bindActivityStream();
      } else {
        _activitySubscription?.cancel();
        emit(DashboardState(
          isLoading: false,
          stats: DashboardStatsModel.empty(),
          recentActivity: [],
          revenueChartData: List.filled(6, 0.0),
        ));
      }
    });
  }

  void bindActivityStream() {
    _activitySubscription?.cancel();
    final slotId = locator<SlotsCubit>().state.selectedSlotId;
    _activitySubscription = _activityRepo.getRecentActivityStream(slotId).listen((activityList) {
      emit(state.copyWith(recentActivity: activityList));
    });
  }

  Future<void> fetchDashboardData() async {
    try {
      emit(state.copyWith(isLoading: true));
      final slotId = locator<SlotsCubit>().state.selectedSlotId;

      // Fetch all required stats concurrently
      final responses = await Future.wait([
        _memberRepo.getTotalMembersCount(slotId),
        _memberRepo.getActiveMembersCount(slotId),
        _seatRepo.getTotalSeatsCount(slotId),
        _seatRepo.getAvailableSeatsCount(slotId),
        _seatRepo.getOccupiedSeatsCount(slotId),
        _paymentRepo.getMonthlyRevenue('all'),
        _paymentRepo.getTodaysCollection('all'),
        _memberRepo.getPendingPaymentsAmount('all'),
        _paymentRepo.getRevenueChartData('all'),
      ]);

      final totalMembers = responses[0] as int;
      final activeMembers = responses[1] as int;
      final totalSeats = responses[2] as int;
      final availableSeats = responses[3] as int;
      final occupiedSeats = responses[4] as int;
      final monthlyRevenue = responses[5] as double;
      final todaysCollection = responses[6] as double;
      final pendingPaymentsAmount = responses[7] as double;
      final chartDataList = responses[8] as List<double>;

      final expiredMembers = totalMembers - activeMembers;
      final expiringSoon = 0; 
      final pendingPayments = pendingPaymentsAmount.toInt();

      final newStats = DashboardStatsModel(
        totalMembers: totalMembers,
        activeMembers: activeMembers,
        expiredMembers: expiredMembers,
        expiringSoon: expiringSoon,
        totalSeats: totalSeats,
        availableSeats: availableSeats,
        occupiedSeats: occupiedSeats,
        pendingPayments: pendingPayments,
        monthlyRevenue: monthlyRevenue,
        todaysCollection: todaysCollection,
      );

      emit(state.copyWith(
        isLoading: false,
        stats: newStats,
        revenueChartData: chartDataList,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  @override
  Future<void> close() {
    _activitySubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
