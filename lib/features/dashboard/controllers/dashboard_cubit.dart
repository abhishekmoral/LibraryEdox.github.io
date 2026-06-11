import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/data/repositories/seats/seat_repository.dart';
import 'package:edox_library/data/repositories/payments/payment_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/features/dashboard/models/dashboard_stats_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';
import 'package:edox_library/features/members/controllers/members_cubit.dart';
import 'package:edox_library/features/seats/controllers/seats_cubit.dart';
import 'package:edox_library/utils/constants/firebase_constants.dart';

class SlotSeatDetails {
  final String slotId;
  final String slotName;
  final String timing;
  final int totalSeats;
  final int availableSeats;
  final int occupiedSeats;

  const SlotSeatDetails({
    required this.slotId,
    required this.slotName,
    required this.timing,
    required this.totalSeats,
    required this.availableSeats,
    required this.occupiedSeats,
  });
}

class DashboardState {
  final bool isLoading;
  final DashboardStatsModel stats;
  final List<ActivityModel> recentActivity;
  final List<double> revenueChartData;
  final List<SlotSeatDetails> slotSeatDetails;

  DashboardState({
    required this.isLoading,
    required this.stats,
    required this.recentActivity,
    required this.revenueChartData,
    required this.slotSeatDetails,
  });

  DashboardState copyWith({
    bool? isLoading,
    DashboardStatsModel? stats,
    List<ActivityModel>? recentActivity,
    List<double>? revenueChartData,
    List<SlotSeatDetails>? slotSeatDetails,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      recentActivity: recentActivity ?? this.recentActivity,
      revenueChartData: revenueChartData ?? this.revenueChartData,
      slotSeatDetails: slotSeatDetails ?? this.slotSeatDetails,
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
  StreamSubscription<SlotsState>? _slotsSubscription;
  StreamSubscription<MembersState>? _membersSubscription;
  StreamSubscription<SeatsState>? _seatsSubscription;

  DashboardCubit() : super(DashboardState(
    isLoading: false,
    stats: DashboardStatsModel.empty(),
    recentActivity: [],
    revenueChartData: List.filled(6, 0.0),
    slotSeatDetails: [],
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
          slotSeatDetails: [],
        ));
      }
    });

    _slotsSubscription = locator<SlotsCubit>().stream.listen((_) {
      fetchDashboardData();
      bindActivityStream();
    });

    _membersSubscription = locator<MembersCubit>().stream.listen((_) {
      fetchDashboardData();
    });

    _seatsSubscription = locator<SeatsCubit>().stream.listen((_) {
      fetchDashboardData();
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
      final String libraryId = AuthenticationRepository.instance.currentUser?.uid ?? '';
      if (libraryId.isEmpty) {
        emit(state.copyWith(isLoading: false));
        return;
      }

      final slotId = locator<SlotsCubit>().state.selectedSlotId;
      final slots = locator<SlotsCubit>().state.slots;

      // Define references
      final seatsCollection = FirebaseFirestore.instance
          .collection(XFirebaseConstants.librariesCollection)
          .doc(libraryId)
          .collection(XFirebaseConstants.seatsCollection);
          
      final membersCollection = FirebaseFirestore.instance
          .collection(XFirebaseConstants.librariesCollection)
          .doc(libraryId)
          .collection(XFirebaseConstants.membersCollection);

      // Run Firestore requests concurrently
      final responses = await Future.wait([
        membersCollection.get(), // 0: All members
        _seatRepo.getTotalSeatsCount('default'), // 1: Total seats
        
        // maintenance seats count query
        seatsCollection
            .where('status', isEqualTo: 'maintenance')
            .count()
            .get(), // 2: Maintenance count
            
        _paymentRepo.getMonthlyRevenue('all'), // 3: Monthly revenue
        _paymentRepo.getTodaysCollection('all'), // 4: Today's collection
        _memberRepo.getPendingPaymentsAmount('all'), // 5: Pending payments
        _paymentRepo.getRevenueChartData('all'), // 6: Chart data
      ]);

      final allMembersSnapshot = responses[0] as QuerySnapshot<Map<String, dynamic>>;
      final totalSeats = responses[1] as int;
      final maintenanceCount = (responses[2] as AggregateQuerySnapshot).count ?? 0;
      final monthlyRevenue = responses[3] as double;
      final todaysCollection = responses[4] as double;
      final pendingPaymentsAmount = responses[5] as double;
      final chartDataList = responses[6] as List<double>;

      // Build slot lookup map
      final slotsCubit = locator<SlotsCubit>();
      final slotMap = {for (var s in slots) s.id: s};
      if (!slotMap.containsKey('default')) {
        slotMap['default'] = SlotModel(
          id: 'default',
          name: 'Complete Shift',
          startTime: '12:00 AM',
          endTime: '11:59 PM',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }

      // Run background cleanup for old deleted members (older than 50 days) in Firestore
      final fiftyDaysAgo = DateTime.now().subtract(const Duration(days: 50));
      final deletedMembersDocs = allMembersSnapshot.docs
          .where((doc) => (doc.data()['status'] as String? ?? 'active') == 'deleted')
          .toList();
          
      for (final doc in deletedMembersDocs) {
        final data = doc.data();
        final deletedAtTimestamp = data['deletedAt'] as Timestamp?;
        if (deletedAtTimestamp != null) {
          final deletedAt = deletedAtTimestamp.toDate();
          if (deletedAt.isBefore(fiftyDaysAgo)) {
            // Delete permanently in Firestore in the background
            doc.reference.delete();
          }
        }
      }

      // Filter out deleted/bin members for all dashboard statistics
      final allDocs = allMembersSnapshot.docs
          .where((doc) => (doc.data()['status'] as String? ?? 'active') != 'deleted')
          .toList();

      // 1. Calculate slot-wise seat details
      final List<SlotSeatDetails> slotDetailsList = [];
      for (final slot in slots) {
        final occupiedSeatNumbers = <String>{};
        for (final doc in allDocs) {
          final data = doc.data();
          final status = data['status'] as String? ?? 'active';
          if (status != 'active') continue;

          final seatNum = data['seatNumber'] as String?;
          if (seatNum == null || seatNum.isEmpty || seatNum == 'Unassigned') continue;

          final memberSlotId = data['slotId'] as String? ?? 'default';
          final memberSlot = slotMap[memberSlotId];
          if (memberSlot == null) continue;

          if (slotsCubit.doSlotsOverlap(
            slot.name, slot.startTime, slot.endTime,
            memberSlot.name, memberSlot.startTime, memberSlot.endTime,
          )) {
            occupiedSeatNumbers.add(seatNum);
          }
        }
        
        final occupiedCount = occupiedSeatNumbers.length;
        final availableCount = (totalSeats - occupiedCount - maintenanceCount).clamp(0, totalSeats);

        slotDetailsList.add(SlotSeatDetails(
          slotId: slot.id,
          slotName: slot.name,
          timing: '${slot.startTime} - ${slot.endTime}',
          totalSeats: totalSeats,
          availableSeats: availableCount,
          occupiedSeats: occupiedCount,
        ));
      }

      // 2. Calculate statistics for the currently selected slotId
      int selectedOccupiedSeats = 0;
      int selectedAvailableSeats = (totalSeats - maintenanceCount).clamp(0, totalSeats);
      
      final currentDetails = slotDetailsList.firstWhereOrNull((d) => d.slotId == slotId);
      if (currentDetails != null) {
        selectedOccupiedSeats = currentDetails.occupiedSeats;
        selectedAvailableSeats = currentDetails.availableSeats;
      } else {
        final viewedSlot = slotMap[slotId] ?? slotMap['default']!;
        final occupiedSeatNumbers = <String>{};
        for (final doc in allDocs) {
          final data = doc.data();
          final status = data['status'] as String? ?? 'active';
          if (status != 'active') continue;

          final seatNum = data['seatNumber'] as String?;
          if (seatNum == null || seatNum.isEmpty || seatNum == 'Unassigned') continue;

          final memberSlotId = data['slotId'] as String? ?? 'default';
          final memberSlot = slotMap[memberSlotId];
          if (memberSlot == null) continue;

          if (slotsCubit.doSlotsOverlap(
            viewedSlot.name, viewedSlot.startTime, viewedSlot.endTime,
            memberSlot.name, memberSlot.startTime, memberSlot.endTime,
          )) {
            occupiedSeatNumbers.add(seatNum);
          }
        }
        selectedOccupiedSeats = occupiedSeatNumbers.length;
        selectedAvailableSeats = (totalSeats - selectedOccupiedSeats - maintenanceCount).clamp(0, totalSeats);
      }

      // Calculate member stats for currently selected slotId
      int selectedTotalMembers = 0;
      int selectedActiveMembers = 0;
      int selectedExpiredMembers = 0;

      if (slotId == 'all') {
        selectedTotalMembers = allDocs.length;
        for (final doc in allDocs) {
          final data = doc.data();
          final status = data['status'] as String? ?? 'active';
          final seatId = data['seatId'] as String? ?? '';
          final seatNumber = data['seatNumber'] as String? ?? '';
          final hasSeat = seatId.isNotEmpty && seatNumber != 'Unassigned';

          if (status == 'active') {
            if (hasSeat) {
              selectedActiveMembers++;
            }
          } else if (status == 'expired') {
            selectedExpiredMembers++;
          }
        }
      } else {
        final viewedSlot = slotMap[slotId] ?? slotMap['default']!;
        for (final doc in allDocs) {
          final data = doc.data();
          final memberSlotId = data['slotId'] as String? ?? 'default';
          final memberSlot = slotMap[memberSlotId];
          if (memberSlot == null) continue;

          if (slotsCubit.doSlotsOverlap(
            viewedSlot.name, viewedSlot.startTime, viewedSlot.endTime,
            memberSlot.name, memberSlot.startTime, memberSlot.endTime,
          )) {
            selectedTotalMembers++;
            final status = data['status'] as String? ?? 'active';
            final seatId = data['seatId'] as String? ?? '';
            final seatNumber = data['seatNumber'] as String? ?? '';
            final hasSeat = seatId.isNotEmpty && seatNumber != 'Unassigned';

            if (status == 'active') {
              if (hasSeat) {
                selectedActiveMembers++;
              }
            } else if (status == 'expired') {
              selectedExpiredMembers++;
            }
          }
        }
      }

      final totalMembers = selectedTotalMembers;
      final expiredMembers = selectedExpiredMembers;
      final expiringSoon = 0; 
      final pendingPayments = pendingPaymentsAmount.toInt();

      final newStats = DashboardStatsModel(
        totalMembers: totalMembers,
        activeMembers: selectedActiveMembers,
        expiredMembers: expiredMembers,
        expiringSoon: expiringSoon,
        totalSeats: totalSeats,
        availableSeats: selectedAvailableSeats,
        occupiedSeats: selectedOccupiedSeats,
        pendingPayments: pendingPayments,
        monthlyRevenue: monthlyRevenue,
        todaysCollection: todaysCollection,
      );

      emit(state.copyWith(
        isLoading: false,
        stats: newStats,
        revenueChartData: chartDataList,
        slotSeatDetails: slotDetailsList,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  @override
  Future<void> close() {
    _activitySubscription?.cancel();
    _authSubscription?.cancel();
    _slotsSubscription?.cancel();
    _membersSubscription?.cancel();
    _seatsSubscription?.cancel();
    return super.close();
  }
}
