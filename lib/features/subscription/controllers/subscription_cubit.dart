import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edox_library/data/repositories/authentication/authentication_repository.dart';
import 'package:edox_library/features/subscription/models/subscription_model.dart';
import 'package:edox_library/utils/constants/firebase_constants.dart';
import 'package:edox_library/data/repositories/library/library_repository.dart';
import 'package:edox_library/bindings/dependency_injection.dart';

abstract class SubscriptionState {}

class SubscriptionInitial extends SubscriptionState {}

class SubscriptionLoading extends SubscriptionState {}

class SubscriptionLoaded extends SubscriptionState {
  final SubscriptionModel subscription;
  SubscriptionLoaded(this.subscription);
}

class SubscriptionFailure extends SubscriptionState {
  final String message;
  SubscriptionFailure(this.message);
}

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;
  String? _userId;

  SubscriptionCubit() : super(SubscriptionInitial()) {
    _init();
  }

  void _init() {
    print('SubscriptionCubit: Initializing...');
    
    // Check initial user immediately
    final currentUser = AuthenticationRepository.instance.currentUser;
    if (currentUser != null) {
      print('SubscriptionCubit: Found current user immediately: ${currentUser.uid}');
      _userId = currentUser.uid;
      fetchSubscriptionRecord(currentUser.uid);
    } else {
      print('SubscriptionCubit: No user found immediately.');
    }

    // Also listen to future changes
    _authSubscription = AuthenticationRepository.instance.authStateChanges.listen((user) {
      if (user != null) {
        print('SubscriptionCubit: Auth state changed. User UID: ${user.uid}');
        if (_userId != user.uid) {
          _userId = user.uid;
          fetchSubscriptionRecord(user.uid);
        }
      } else {
        print('SubscriptionCubit: Auth state changed to null.');
        _userId = null;
        emit(SubscriptionInitial());
      }
    });
  }

  Future<void> fetchSubscriptionRecord(String userId) async {
    try {
      print('SubscriptionCubit: Fetching subscription doc for UID: $userId');
      emit(SubscriptionLoading());
      
      final doc = await _db
          .collection(XFirebaseConstants.subscriptionsCollection)
          .doc(userId)
          .get();

      // Fetch library details to include libraryName and mobile in subscription document
      String libName = 'EdoxLibrary';
      String ownerMobile = 'Not provided';
      try {
        final libDetails = await locator<LibraryRepository>().fetchLibraryDetails(userId);
        if (libDetails.id.isNotEmpty) {
          libName = libDetails.libraryName;
          ownerMobile = libDetails.mobile;
        }
      } catch (e) {
        print('SubscriptionCubit: Error loading library details: $e');
      }

      if (doc.exists) {
        print('SubscriptionCubit: Subscription document found. Data: ${doc.data()}');
        final subModel = SubscriptionModel.fromSnapshot(doc);
        
        // Sync actual details if they differ and are non-empty
        final actualLibName = libName != 'EdoxLibrary' ? libName : (subModel.libraryName.isNotEmpty ? subModel.libraryName : 'EdoxLibrary');
        final actualMobile = ownerMobile != 'Not provided' ? ownerMobile : (subModel.mobile.isNotEmpty ? subModel.mobile : 'Not provided');

        if (subModel.libraryName != actualLibName || subModel.mobile != actualMobile || subModel.libraryName.isEmpty || subModel.mobile.isEmpty) {
          print('SubscriptionCubit: Library info out of sync or empty. Syncing in Firestore...');
          final updatedSub = subModel.copyWith(
            libraryName: actualLibName,
            mobile: actualMobile,
          );

          await _db
              .collection(XFirebaseConstants.subscriptionsCollection)
              .doc(userId)
              .update(updatedSub.toJson());
          
          print('SubscriptionCubit: Successfully synced library info in Firestore for subscriptions/$userId');
          emit(SubscriptionLoaded(updatedSub));
        } else {
          emit(SubscriptionLoaded(subModel));
        }
      } else {
        print('SubscriptionCubit: Subscription document does not exist. Seeding new trial...');
        
        // Automatically seed a 30-day trial plan if none exists
        final trialSub = SubscriptionModel(
          id: userId,
          planName: 'Trial',
          startDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          status: 'active',
          billing: 'monthly',
          createdAt: DateTime.now(),
          libraryName: libName,
          mobile: ownerMobile,
        );

        await _db
            .collection(XFirebaseConstants.subscriptionsCollection)
            .doc(userId)
            .set(trialSub.toJson());

        print('SubscriptionCubit: Successfully seeded trial in Firestore under subscriptions/$userId');
        emit(SubscriptionLoaded(trialSub));
      }
    } catch (e, stackTrace) {
      print('SubscriptionCubit: Error loading subscription: $e');
      print(stackTrace);
      emit(SubscriptionFailure(e.toString()));
    }
  }

  Future<void> updateLibraryInfo({required String libraryName, required String mobile}) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      print('SubscriptionCubit: Direct update of library info in subscription: $libraryName, $mobile');
      final doc = await _db
          .collection(XFirebaseConstants.subscriptionsCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        final subModel = SubscriptionModel.fromSnapshot(doc);
        final updatedSub = subModel.copyWith(
          libraryName: libraryName,
          mobile: mobile,
        );
        await _db
            .collection(XFirebaseConstants.subscriptionsCollection)
            .doc(userId)
            .update(updatedSub.toJson());
        emit(SubscriptionLoaded(updatedSub));
      } else {
        final trialSub = SubscriptionModel(
          id: userId,
          planName: 'Trial',
          startDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 30)),
          status: 'active',
          billing: 'monthly',
          createdAt: DateTime.now(),
          libraryName: libraryName,
          mobile: mobile,
        );

        await _db
            .collection(XFirebaseConstants.subscriptionsCollection)
            .doc(userId)
            .set(trialSub.toJson());
        emit(SubscriptionLoaded(trialSub));
      }
    } catch (e) {
      print('SubscriptionCubit: Error in updateLibraryInfo: $e');
    }
  }

  Future<void> updateSubscriptionAfterPurchase(String planName, String billing) async {
    final userId = _userId;
    if (userId == null) return;

    try {
      DateTime baseDate = DateTime.now();
      
      // If there is an existing active subscription, extend it from its current expiry date
      if (state is SubscriptionLoaded) {
        final currentSub = (state as SubscriptionLoaded).subscription;
        if (currentSub.isActive) {
          baseDate = currentSub.expiryDate;
        }
      }

      emit(SubscriptionLoading());

      // Premium plan is 90 days, yearly is 365, others (e.g. Basic) are 30 days
      int days = 30;
      if (planName.toLowerCase().contains('premium')) {
        days = 90;
      } else if (billing.toLowerCase() == 'yearly') {
        days = 365;
      }

      // Fetch library details to include libraryName and mobile in subscription document
      String libName = 'EdoxLibrary';
      String ownerMobile = 'Not provided';
      try {
        final libDetails = await locator<LibraryRepository>().fetchLibraryDetails(userId);
        if (libDetails.id.isNotEmpty) {
          libName = libDetails.libraryName;
          ownerMobile = libDetails.mobile;
        }
      } catch (e) {
        print('SubscriptionCubit: Error loading library details for upgrade: $e');
      }

      final newSub = SubscriptionModel(
        id: userId,
        planName: planName,
        startDate: DateTime.now(),
        expiryDate: baseDate.add(Duration(days: days)),
        status: 'active',
        billing: billing,
        createdAt: DateTime.now(),
        libraryName: libName,
        mobile: ownerMobile,
      );

      await _db
          .collection(XFirebaseConstants.subscriptionsCollection)
          .doc(userId)
          .set(newSub.toJson());

      emit(SubscriptionLoaded(newSub));
    } catch (e) {
      emit(SubscriptionFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
