import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/seats/seat_repository.dart';
import 'package:edox_library/data/repositories/activity/activity_repository.dart';
import 'package:edox_library/features/seats/models/seat_model.dart';
import 'package:edox_library/features/dashboard/models/activity_model.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';
import 'package:edox_library/features/members/controllers/members_cubit.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/utils/constants/colors.dart';

class SeatsState {
  final List<SeatModel> allSeats;
  final String searchQuery;
  final bool isGridView;
  final bool isAddingSeats;
  final String currentSlotId;

  SeatsState({
    required this.allSeats,
    required this.searchQuery,
    required this.isGridView,
    required this.isAddingSeats,
    required this.currentSlotId,
  });

  SeatsState copyWith({
    List<SeatModel>? allSeats,
    String? searchQuery,
    bool? isGridView,
    bool? isAddingSeats,
    String? currentSlotId,
  }) {
    return SeatsState(
      allSeats: allSeats ?? this.allSeats,
      searchQuery: searchQuery ?? this.searchQuery,
      isGridView: isGridView ?? this.isGridView,
      isAddingSeats: isAddingSeats ?? this.isAddingSeats,
      currentSlotId: currentSlotId ?? this.currentSlotId,
    );
  }
}

class SeatsCubit extends Cubit<SeatsState> {
  final _seatRepository = SeatRepository.instance;
  final _activityRepository = ActivityRepository.instance;
  StreamSubscription<List<SeatModel>>? _seatsSubscription;
  StreamSubscription<User?>? _authSubscription;

  SeatsCubit() : super(SeatsState(
    allSeats: [],
    searchQuery: '',
    isGridView: true,
    isAddingSeats: false,
    currentSlotId: 'default',
  )) {
    _init();
  }

  void _init() {
    _authSubscription = AuthenticationRepository.instance.authStateChanges.listen((user) {
      if (user != null) {
        final activeSlotId = locator<SlotsCubit>().state.selectedSlotId;
        onSelectedSlotChanged(activeSlotId);
      } else {
        _seatsSubscription?.cancel();
        emit(SeatsState(
          allSeats: [],
          searchQuery: '',
          isGridView: state.isGridView,
          isAddingSeats: false,
          currentSlotId: 'default',
        ));
      }
    });
  }

  void onSelectedSlotChanged(String slotId) {
    _seatsSubscription?.cancel();
    _seatsSubscription = _seatRepository.getAllSeatsStream(slotId).listen((seatsList) {
      emit(state.copyWith(allSeats: seatsList, currentSlotId: slotId));
    });
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  void toggleViewMode() {
    emit(state.copyWith(isGridView: !state.isGridView));
  }

  List<SeatModel> getResolvedSeatsForSlot(String slotId, {String? excludeMemberId}) {
    final rawSeats = state.allSeats;
    
    // Deduplicate physical seats by seatNumber to prevent duplicates in the grid/list.
    // If a seat has a status of 'maintenance' in any of the duplicate records, preserve it.
    final seen = <String, SeatModel>{};
    for (var seat in rawSeats) {
      final existing = seen[seat.seatNumber];
      if (existing == null || (seat.status == 'maintenance' && existing.status != 'maintenance')) {
        seen[seat.seatNumber] = seat;
      }
    }
    final seats = seen.values.toList();
    // Sort seats by seatNumber to keep consistent order
    seats.sort((a, b) => a.seatNumber.compareTo(b.seatNumber));
    
    final membersCubit = locator<MembersCubit>();
    final members = membersCubit.state.allMembers;

    final slotsCubit = locator<SlotsCubit>();
    
    final slotMap = <String, SlotModel>{
      'default': SlotModel(
        id: 'default', name: 'Complete',
        startTime: '12:00 AM', endTime: '11:59 PM',
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      ),
    };
    for (final s in slotsCubit.state.slots) {
      slotMap[s.id] = s;
    }

    // Get the viewed slot's time range (needed for overlap comparison)
    final viewedSlot = slotMap[slotId];

    return seats.map((seat) {
      // Find all active members assigned to this seat, excluding the specified member id if any
      final seatMembers = members.where(
        (m) => m.seatNumber == seat.seatNumber && m.status == 'active' && (excludeMemberId == null || m.id != excludeMemberId)
      ).toList();

      MemberModel? member;
      if (slotId == 'all') {
        // "All" view: any active member on this seat counts
        member = seatMembers.firstOrNull;
      } else if (viewedSlot == null) {
        // Unknown slot: fall back to exact match only
        member = seatMembers.firstWhereOrNull((m) => m.slotId == slotId);
      } else {
        // Time-based overlap detection:
        // A seat is occupied if any member is booked in a slot whose time
        // range overlaps with the currently viewed slot's time range.
        // Priority: exact slot match first, then any overlapping slot.
        member = seatMembers.firstWhereOrNull((m) => m.slotId == slotId);
        member ??= seatMembers.firstWhereOrNull((m) {
          final memberSlot = slotMap[m.slotId];
          if (memberSlot == null) return false;
          return slotsCubit.doSlotsOverlap(
            viewedSlot.name, viewedSlot.startTime, viewedSlot.endTime,
            memberSlot.name, memberSlot.startTime, memberSlot.endTime,
          );
        });
      }
      
      if (member != null) {
        return seat.copyWith(
          status: 'occupied',
          isOccupied: true,
          memberId: member.id,
          memberName: member.fullName,
          memberMobile: member.mobile,
          memberExpiry: member.expiryDate,
        );
      } else {
        final baseStatus = seat.status == 'occupied' ? 'available' : seat.status;
        return seat.copyWith(
          status: baseStatus,
          isOccupied: false,
          memberId: '',
          memberName: '',
          memberMobile: '',
          memberExpiry: null,
        );
      }
    }).toList();
  }

  /// Calculates a list of slot names that are still free for a given seat,
  /// optionally excluding a member (useful when editing a member).
  List<String> getFreeSlotNamesForSeat(String seatNumber, {String? excludeMemberId}) {
    final membersCubit = locator<MembersCubit>();
    final members = membersCubit.state.allMembers;

    final slotsCubit = locator<SlotsCubit>();

    final allSystemSlots = [
      SlotModel(
        id: 'default',
        name: 'Complete',
        startTime: '12:00 AM',
        endTime: '11:59 PM',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ...slotsCubit.state.slots,
    ];

    final slotMap = {for (var s in allSystemSlots) s.id: s};

    final seatMembers = members.where((m) {
      if (m.seatNumber != seatNumber || m.status != 'active') return false;
      if (excludeMemberId != null && m.id == excludeMemberId) return false;
      return true;
    }).toList();

    final freeSlotNames = <String>[];

    for (final systemSlot in allSystemSlots) {
      final isOccupied = seatMembers.any((m) {
        final memberSlot = slotMap[m.slotId];
        if (memberSlot == null) return false;
        return slotsCubit.doSlotsOverlap(
          systemSlot.name, systemSlot.startTime, systemSlot.endTime,
          memberSlot.name, memberSlot.startTime, memberSlot.endTime,
        );
      });

      if (!isOccupied) {
        freeSlotNames.add(systemSlot.name);
      }
    }

    return freeSlotNames;
  }

  List<SeatModel> get resolvedSeats {
    return getResolvedSeatsForSlot(state.currentSlotId);
  }

  List<SeatModel> get filteredSeats {
    final list = resolvedSeats;
    if (state.searchQuery.isEmpty) return list;
    final q = state.searchQuery.toLowerCase();
    return list.where((s) {
      return s.seatNumber.toLowerCase().contains(q) ||
          s.memberName.toLowerCase().contains(q) ||
          s.memberMobile.contains(q) ||
          s.status.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> addSeats(BuildContext context, String prefix, int start, int count) async {
    try {
      emit(state.copyWith(isAddingSeats: true));
      
      for (int i = 0; i < count; i++) {
        final num = start + i;
        final seatNum = '$prefix-${num.toString().padLeft(2, '0')}';
        
        final newSeat = SeatModel(
          id: '',
          seatNumber: seatNum,
          status: 'available',
          isOccupied: false,
          slotId: 'default',
          memberId: '',
          memberName: '',
          memberMobile: '',
          memberExpiry: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _seatRepository.saveSeatRecord(newSeat);
      }

      final activity = ActivityModel(
        id: '',
        type: 'seat',
        title: 'Seats Added',
        description: 'Added $count new seats ($prefix)',
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);

      Navigator.pop(context); // close sheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$count seat${count > 1 ? 's' : ''} added successfully!'), backgroundColor: XColors.accent),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add seats: $e'), backgroundColor: XColors.error),
      );
    } finally {
      emit(state.copyWith(isAddingSeats: false));
    }
  }

  Future<void> updateSeat(BuildContext context, SeatModel seat) async {
    try {
      await _seatRepository.updateSeat(seat);
      
      final activity = ActivityModel(
        id: '',
        type: 'seat',
        title: 'Seat Updated',
        description: 'Seat ${seat.seatNumber} was updated',
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seat updated successfully!'), backgroundColor: XColors.success),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update seat: $e'), backgroundColor: XColors.error),
      );
    }
  }

  Future<void> deleteSeat(BuildContext context, SeatModel seat) async {
    try {
      await _seatRepository.deleteSeat(seat.id);
      
      final activity = ActivityModel(
        id: '',
        type: 'seat',
        title: 'Seat Deleted',
        description: 'Seat ${seat.seatNumber} was removed',
        createdAt: DateTime.now(),
      );
      await _activityRepository.saveActivity(activity);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seat deleted successfully.'), backgroundColor: XColors.success),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete seat: $e'), backgroundColor: XColors.error),
      );
    }
  }

  @override
  Future<void> close() {
    _seatsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
