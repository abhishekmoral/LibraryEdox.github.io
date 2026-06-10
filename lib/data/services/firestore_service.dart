import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edox_library/bindings/dependency_injection.dart';

import 'package:edox_library/utils/logging/logger.dart';

/// A service helper that exposes generic CRUD helpers over [FirebaseFirestore].
///
/// All document/collection paths should be built by the caller using
/// [XFirebaseConstants] to enforce multi-tenant isolation
/// (e.g. `libraries/$libraryId/members`).
class FirestoreService {
  FirestoreService._();
  static final FirestoreService _instance = FirestoreService._();
  factory FirestoreService() => _instance;

  static FirestoreService get instance => locator<FirestoreService>();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ──────────────────────────── Read ─────────────────────────────

  /// Returns a single document at the given Firestore [path].
  Future<DocumentSnapshot> getDocument(String path) async {
    try {
      XLoggerHelper.debug('Firestore GET → $path');
      return await _db.doc(path).get();
    } catch (e, st) {
      XLoggerHelper.error('Firestore GET failed: $path', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Returns all documents in the collection at [path].
  ///
  /// Use the optional [queryBuilder] to add where-clauses, ordering, limits, etc.
  Future<QuerySnapshot> getCollection(
    String path, {
    Query Function(Query)? queryBuilder,
  }) async {
    try {
      XLoggerHelper.debug('Firestore COLLECTION GET → $path');
      Query query = _db.collection(path);
      if (queryBuilder != null) query = queryBuilder(query);
      return await query.get();
    } catch (e, st) {
      XLoggerHelper.error('Firestore COLLECTION GET failed: $path', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Returns a realtime stream of documents in the collection at [path].
  Stream<QuerySnapshot> getCollectionStream(
    String path, {
    Query Function(Query)? queryBuilder,
  }) {
    try {
      XLoggerHelper.debug('Firestore STREAM → $path');
      Query query = _db.collection(path);
      if (queryBuilder != null) query = queryBuilder(query);
      return query.snapshots();
    } catch (e, st) {
      XLoggerHelper.error('Firestore STREAM failed: $path', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ──────────────────────────── Write ────────────────────────────

  /// Creates or overwrites the document at [path] with [data].
  Future<void> setDocument(String path, Map<String, dynamic> data) async {
    try {
      XLoggerHelper.debug('Firestore SET → $path');
      await _db.doc(path).set(data);
    } catch (e, st) {
      XLoggerHelper.error('Firestore SET failed: $path', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Merges [data] into the existing document at [path].
  Future<void> updateDocument(String path, Map<String, dynamic> data) async {
    try {
      XLoggerHelper.debug('Firestore UPDATE → $path');
      await _db.doc(path).update(data);
    } catch (e, st) {
      XLoggerHelper.error('Firestore UPDATE failed: $path', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Adds a new document with an auto-generated ID to the collection at [path].
  Future<DocumentReference> addToCollection(
    String path,
    Map<String, dynamic> data,
  ) async {
    try {
      XLoggerHelper.debug('Firestore ADD → $path');
      return await _db.collection(path).add(data);
    } catch (e, st) {
      XLoggerHelper.error('Firestore ADD failed: $path', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ──────────────────────────── Delete ───────────────────────────

  /// Deletes the document at [path].
  Future<void> deleteDocument(String path) async {
    try {
      XLoggerHelper.debug('Firestore DELETE → $path');
      await _db.doc(path).delete();
    } catch (e, st) {
      XLoggerHelper.error('Firestore DELETE failed: $path', error: e, stackTrace: st);
      rethrow;
    }
  }

  // ──────────────────────────── Batch ────────────────────────────

  /// Executes multiple write operations atomically.
  ///
  /// Each element in [operations] is a map with:
  /// - `'type'`  – `'set'` | `'update'` | `'delete'`
  /// - `'path'`  – Firestore document path
  /// - `'data'`  – document data (not needed for delete)
  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      XLoggerHelper.debug('Firestore BATCH → ${operations.length} operations');
      final batch = _db.batch();

      for (final op in operations) {
        final type = op['type'] as String;
        final path = op['path'] as String;
        final ref = _db.doc(path);

        switch (type) {
          case 'set':
            batch.set(ref, op['data'] as Map<String, dynamic>);
            break;
          case 'update':
            batch.update(ref, op['data'] as Map<String, dynamic>);
            break;
          case 'delete':
            batch.delete(ref);
            break;
          default:
            XLoggerHelper.warning('Unknown batch operation type: $type');
        }
      }

      await batch.commit();
      XLoggerHelper.info('Firestore BATCH committed successfully');
    } catch (e, st) {
      XLoggerHelper.error('Firestore BATCH failed', error: e, stackTrace: st);
      rethrow;
    }
  }
}
