import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hungryowl/models/users.dart';
import 'package:hungryowl/types/internal_types.dart';

bool userDeletedIgnoreNull = false;

class UserState {
  final User? user;
  UserState({required this.user});

  UserState copyWith({User? user}) {
    return UserState(user: user ?? this.user);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier(ref);
});

class UserNotifier extends StateNotifier<UserState> {
  final Ref ref;

  UserNotifier(this.ref) : super(UserState(user: null)) {
    _loadUserFromStream();
  }

  void _loadUserFromStream() {
    ref.listen<AsyncValue<User?>>(usersProvider, (previous, next) {
      next.when(
        data: (user) async {
          if (userDeletedIgnoreNull) {
            return;
          }
          if (user == null) {
            await createUser();
            return;
          }
          state = state.copyWith(user: user);
          String userId = user.anonId;
          if (userId == 'BRUH') {
            // yikes 😳
            userId = user.id;
          }
        },
        loading: () {},
        error: (error, stack) {
          debugPrint("Error loading user: $error");
        },
      );
    });
  }
}
