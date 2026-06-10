import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:edox_library/bindings/dependency_injection.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/data/repositories/slots/slot_repository.dart';
import 'package:edox_library/features/slots/models/slot_model.dart';
import 'package:edox_library/features/seats/controllers/seats_cubit.dart';
import 'package:edox_library/features/members/controllers/members_cubit.dart';
import 'package:edox_library/utils/constants/colors.dart';

class SlotsState {
  final List<SlotModel> slots;
  final SlotModel selectedSlot;

  SlotsState({required this.slots, required this.selectedSlot});

  String get selectedSlotId => selectedSlot.id;
}

class SlotsCubit extends Cubit<SlotsState> {
  final _slotRepo = SlotRepository.instance;
  StreamSubscription<List<SlotModel>>? _slotsSubscription;
  StreamSubscription<User?>? _authSubscription;

  SlotsCubit() : super(SlotsState(
    slots: [],
    selectedSlot: SlotModel(
      id: 'default',
      name: 'Complete',
      startTime: '12:00 AM',
      endTime: '11:59 PM',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  )) {
    _init();
  }

  void _init() {
    _authSubscription = AuthenticationRepository.instance.authStateChanges.listen((user) {
      if (user != null) {
        _slotsSubscription?.cancel();
        _slotsSubscription = _slotRepo.getSlotsStream().listen((loadedSlots) {
          emit(SlotsState(
            slots: loadedSlots,
            selectedSlot: state.selectedSlot,
          ));
        });
      } else {
        _slotsSubscription?.cancel();
        emit(SlotsState(
          slots: [],
          selectedSlot: SlotModel(
            id: 'default',
            name: 'Complete',
            startTime: '12:00 AM',
            endTime: '11:59 PM',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ));
      }
    });
  }

  void selectSlot(SlotModel slot) {
    emit(SlotsState(slots: state.slots, selectedSlot: slot));
    
    // Refresh other Cubits
    if (locator.isRegistered<SeatsCubit>()) {
      locator<SeatsCubit>().onSelectedSlotChanged(slot.id);
    }
    if (locator.isRegistered<MembersCubit>()) {
      locator<MembersCubit>().onSelectedSlotChanged(slot.id);
    }
  }

  /// Parse a time string like "7:00 AM", "12:00 AM", "11:59 PM" into total minutes from midnight (0–1439).
  int _parseTimeToMinutes(String time) {
    final parts = time.trim().split(' ');
    final period = parts[1].toUpperCase();
    final hm = parts[0].split(':');
    int hour = int.parse(hm[0]);
    final int minute = int.parse(hm[1]);

    if (period == 'AM') {
      if (hour == 12) hour = 0;
    } else {
      if (hour != 12) hour += 12;
    }
    return hour * 60 + minute;
  }

  /// Simple overlap check for two non-wrapping ranges.
  bool _simpleOverlap(int startA, int endA, int startB, int endB) {
    return startA < endB && startB < endA;
  }

  /// Check whether two time ranges overlap, handling wrapping past midnight.
  bool _doTimesOverlap(int startA, int endA, int startB, int endB) {
    final aWraps = endA <= startA;
    final bWraps = endB <= startB;

    if (!aWraps && !bWraps) {
      return _simpleOverlap(startA, endA, startB, endB);
    }
    if (aWraps && bWraps) {
      return true;
    }
    if (aWraps) {
      return _simpleOverlap(startA, 1440, startB, endB) ||
             _simpleOverlap(0, endA, startB, endB);
    }
    return _simpleOverlap(startA, endA, startB, 1440) ||
           _simpleOverlap(startA, endA, 0, endB);
  }

  /// Whether a time string pair represents a "complete day" (12:00 AM – 11:59 PM).
  bool _isCompleteDay(String startTime, String endTime) {
    return startTime == '12:00 AM' && endTime == '11:59 PM';
  }

  String _normalizeSlotName(String name) {
    final n = name.toLowerCase().trim();
    if (n.contains('whole') || n.contains('default') || n.contains('full') || n.contains('complete')) {
      return 'whole_day';
    }
    if (n.contains('morning')) {
      return 'morning';
    }
    if (n.contains('evening') || n.contains('eveining')) {
      return 'evening';
    }
    if (n.contains('night')) {
      return 'night';
    }
    if (n.contains('day')) {
      return 'day';
    }
    return n;
  }

  bool _getMatrixConflict(String normA, String normB) {
    if (normA == 'whole_day' || normB == 'whole_day') return true;
    if (normA == normB) return true;
    if (normA == 'day') {
      return normB == 'morning' || normB == 'evening';
    }
    if (normB == 'day') {
      return normA == 'morning' || normA == 'evening';
    }
    return false;
  }

  /// Check if two slots overlap by their names and time strings.
  bool doSlotsOverlap(String nameA, String startA, String endA, String nameB, String startB, String endB) {
    final normA = _normalizeSlotName(nameA);
    final normB = _normalizeSlotName(nameB);
    
    final standardSlots = {'whole_day', 'day', 'night', 'morning', 'evening'};
    
    if (standardSlots.contains(normA) && standardSlots.contains(normB)) {
      return _getMatrixConflict(normA, normB);
    }
    
    if (normA == 'whole_day' || normB == 'whole_day') return true;
    
    return _doTimesOverlap(
      _parseTimeToMinutes(startA), _parseTimeToMinutes(endA),
      _parseTimeToMinutes(startB), _parseTimeToMinutes(endB),
    );
  }

  Future<bool> createSlot(BuildContext context, String name, String startTime, String endTime) async {
    final isNewCompleteDay = _isCompleteDay(startTime, endTime);
    
    final completeDayCount = state.slots.where((s) => _isCompleteDay(s.startTime, s.endTime)).length;
    final standardCount = state.slots.length - completeDayCount;

    if (isNewCompleteDay) {
      if (completeDayCount >= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Only 1 complete day slot can be created.'),
            backgroundColor: XColors.error,
          ),
        );
        return false;
      }
    } else {
      if (standardCount >= 3) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Maximum of 3 slots with custom timings can be created. Please delete one to add a new slot.'),
            backgroundColor: XColors.error,
          ),
        );
        return false;
      }
    }

    final newStart = _parseTimeToMinutes(startTime);
    final newEnd = _parseTimeToMinutes(endTime);

    if (newStart == newEnd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Start time and end time cannot be the same.'),
          backgroundColor: XColors.error,
        ),
      );
      return false;
    }

    final newNorm = _normalizeSlotName(name);
    final standardSlots = {'whole_day', 'day', 'night', 'morning', 'evening'};

    for (final existing in state.slots) {
      final existingNorm = _normalizeSlotName(existing.name);
      
      if (standardSlots.contains(newNorm) && standardSlots.contains(existingNorm)) {
        if (newNorm == existingNorm || 
            (startTime == existing.startTime && endTime == existing.endTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A slot with this type/name or time range already exists.'),
              backgroundColor: XColors.error,
            ),
          );
          return false;
        }
        continue;
      }
      
      final exStart = _parseTimeToMinutes(existing.startTime);
      final exEnd = _parseTimeToMinutes(existing.endTime);

      if (_doTimesOverlap(newStart, newEnd, exStart, exEnd)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$name" ($startTime – $endTime) overlaps with "${existing.name}" (${existing.startTime} – ${existing.endTime}). Please choose a different time range.'),
            backgroundColor: XColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
        return false;
      }
    }

    try {
      final newSlot = SlotModel(
        id: '',
        name: name,
        startTime: startTime,
        endTime: endTime,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _slotRepo.saveSlotRecord(newSlot);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Slot "$name" created successfully!')),
      );
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create slot: $e'), backgroundColor: XColors.error),
      );
      return false;
    }
  }

  Future<void> deleteSlot(BuildContext context, String slotId) async {
    try {
      if (state.selectedSlotId == slotId) {
        emit(SlotsState(
          slots: state.slots,
          selectedSlot: SlotModel(
            id: 'default',
            name: 'Complete',
            startTime: '12:00 AM',
            endTime: '11:59 PM',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ));
      }
      await _slotRepo.deleteSlot(slotId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Slot deleted successfully!'),
          backgroundColor: XColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete slot: $e'),
          backgroundColor: XColors.error,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _slotsSubscription?.cancel();
    _authSubscription?.cancel();
    return super.close();
  }
}
