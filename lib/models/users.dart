import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungryowl/services/anon_id_generator.dart';
import 'package:hungryowl/types/internal_types.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/utils/value_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:hungryowl/services/db.dart';

final userStore = StoreRef<String, Map<String, dynamic>>('user');

final usersProvider = StreamProvider.autoDispose<User?>((ref) {
  final db = Db().db;
  final controller = StreamController<User?>();

  final subscription =
      userStore.record('user').onSnapshot(db).listen((snapshot) {
    if (snapshot != null) {
      controller.add(mapToUser(snapshot.value));
    } else {
      controller.add(null);
    }
  });

  ref.onDispose(() {
    subscription.cancel();
    controller.close();
  });

  return controller.stream;
});

User mapToUser(Map data) {
  return User(
    anonId: data['anonId'],
    id: data['id'],
    createdAt: data['createdAt'],
    updatedAt: data['updatedAt'],
    deletedAt: data['deletedAt'],
    version: data['version'],
    symptoms: List<String>.from(data['symptoms']),
    onboarded: data['onboarded'],
    leftReview: data['leftReview'],
    scanCount: data['scanCount'],
  );
}

Future<Map<String, dynamic>> createUser() async {
  debugPrint("Creating new user...");

  String uid = Uuid().v4();

  try {
    final userData = User(
      id: uid,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      deletedAt: null,
      anonId: getAnonId(uid),
      version: DateTime.now().millisecondsSinceEpoch,
      symptoms: [],
      onboarded: false,
      leftReview: false,
      scanCount: 0,
    );
    final mapUser = userData.toMap();
    await userStore.record('user').put(Db().db, mapUser);
    return mapUser;
  } catch (e) {
    throw Exception('Failed to create user in database: ${e.toString()}');
  }
}

Future<void> updateUser({
  required Map<String, dynamic> updatedData,
}) async {
  try {
    updatedData['updatedAt'] = DateTime.now().millisecondsSinceEpoch;
    await Db().db.transaction((txn) async {
      final userRecord = userStore.record('user');
      final currentData = await userRecord.get(txn);

      if (currentData == null) {
        throw Exception('User not found');
      }
      final mergedData = Map<String, dynamic>.from(cloneMap(currentData))
        ..addAll(updatedData);
      await userRecord.put(txn, mergedData);
    });
  } catch (e) {
    throw Exception('Failed to update user in database: ${e.toString()}');
  }
}

Future<String> getUserId() async {
  final userRecord = userStore.record('user');
  final userData = await userRecord.get(Db().db);
  return userData!['id'];
}

Future<void> deleteUser() async {
  try {
    await userStore.record("user").delete(Db().db);
  } catch (e) {
    throw Exception('Failed to delete user from database: ${e.toString()}');
  }
}
