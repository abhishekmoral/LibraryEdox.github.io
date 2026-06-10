import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/members/member_repository.dart';
import 'package:edox_library/features/members/models/member_model.dart';
import 'package:edox_library/features/slots/controllers/slots_cubit.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';

class MembersState {
  final List<MemberModel> allMembers;
  final List<MemberModel> displayMembersList;
  final bool isLoading;
  final String searchQuery;
  final String selectedFilter;
  final String currentSlotId;

  MembersState({
    required this.allMembers,
    required this.displayMembersList,
    required this.isLoading,
    required this.searchQuery,
    required this.selectedFilter,
    required this.currentSlotId,
  });

  MembersState copyWith({
    List<MemberModel>? allMembers,
    List<MemberModel>? displayMembersList,
    bool? isLoading,
    String? searchQuery,
    String? selectedFilter,
    String? currentSlotId,
  }) {
    return MembersState(
      allMembers: allMembers ?? this.allMembers,
      displayMembersList: displayMembersList ?? this.displayMembersList,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      currentSlotId: currentSlotId ?? this.currentSlotId,
    );
  }
}

class MembersCubit extends Cubit<MembersState> {
  final _memberRepository = MemberRepository.instance;
  StreamSubscription<List<MemberModel>>? _membersSubscription;
  StreamSubscription<User?>? _authSubscription;
  final searchController = TextEditingController();
  final filters = ['All', 'Active', 'Expired', 'Expiring Soon'];

  MembersCubit() : super(MembersState(
    allMembers: [],
    displayMembersList: [],
    isLoading: false,
    searchQuery: '',
    selectedFilter: 'All',
    currentSlotId: 'default',
  )) {
    _init();
  }

  void _init() {
    _authSubscription = AuthenticationRepository.instance.authStateChanges.listen((user) {
      if (user != null) {
        fetchMembers();
      } else {
        _membersSubscription?.cancel();
        emit(MembersState(
          allMembers: [],
          displayMembersList: [],
          isLoading: false,
          searchQuery: '',
          selectedFilter: 'All',
          currentSlotId: 'default',
        ));
      }
    });
  }

  void fetchMembers() {
    emit(state.copyWith(isLoading: true));
    _membersSubscription?.cancel();
    try {
      _membersSubscription = _memberRepository.getAllMembersStream('all').listen((membersList) {
        emit(state.copyWith(allMembers: membersList, isLoading: false));
        _updateList();
      }, onError: (e) {
        emit(state.copyWith(isLoading: false));
      });
    } catch (e) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void onSelectedSlotChanged(String slotId) {
    emit(state.copyWith(currentSlotId: slotId));
    _updateList();
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _updateList();
  }

  void setSelectedFilter(String filter) {
    emit(state.copyWith(selectedFilter: filter));
    _updateList();
  }

  void clearSearch() {
    searchController.clear();
    emit(state.copyWith(searchQuery: ''));
    _updateList();
  }

  void _updateList() {
    final slotId = state.currentSlotId;
    final slotsCubit = locator<SlotsCubit>();

    // Build a slot map for time-range comparison
    final slotMap = <String, SlotModel>{
      'default': SlotModel(
        id: 'default',
        name: 'Complete',
        startTime: '12:00 AM',
        endTime: '11:59 PM',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    };
    for (final s in slotsCubit.state.slots) {
      slotMap[s.id] = s;
    }

    final viewedSlot = slotMap[slotId];

    // Filter by slot first (using time-based overlap matching seat occupancy)
    var list = state.allMembers.where((m) {
      if (slotId == 'all') return true;
      if (m.slotId == slotId) return true;
      
      final memberSlot = slotMap[m.slotId];
      if (viewedSlot == null || memberSlot == null) return false;
      
      return slotsCubit.doSlotsOverlap(
        viewedSlot.name, viewedSlot.startTime, viewedSlot.endTime,
        memberSlot.name, memberSlot.startTime, memberSlot.endTime,
      );
    }).toList();

    // Apply status filter
    final filter = state.selectedFilter;
    if (filter == 'Active') {
      list = list.where((m) => m.status == 'active').toList();
    } else if (filter == 'Expired') {
      list = list.where((m) => m.status == 'expired').toList();
    } else if (filter == 'Expiring Soon') {
      list = list.where((m) => m.isExpiringSoon).toList();
    }
    
    // Apply search
    final q = state.searchQuery.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((m) =>
        m.fullName.toLowerCase().contains(q) ||
        m.mobile.contains(q) ||
        m.seatNumber.toLowerCase().contains(q) ||
        m.email.toLowerCase().contains(q)
      ).toList();
    }

    emit(state.copyWith(displayMembersList: list));
  }

  @override
  Future<void> close() {
    _membersSubscription?.cancel();
    _authSubscription?.cancel();
    searchController.dispose();
    return super.close();
  }
}
