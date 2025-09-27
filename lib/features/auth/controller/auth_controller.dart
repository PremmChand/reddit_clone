import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:reddit_clone/core/failure.dart';
import 'package:reddit_clone/core/utils.dart';
import 'package:reddit_clone/features/auth/repository/auth_repository.dart';
import 'package:reddit_clone/models/user_model.dart';

final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
  (ref) => AuthController(
    authRepository: ref.read(authRepositoryProvider),
    ref: ref,
  ),
);

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController({required AuthRepository authRepository, required Ref ref})
    : _authRepository = authRepository,
      _ref = ref,
      super(false); 

  Stream<User?> get authStateChange => _authRepository.authStateChange;

  Future<void> signInWithGoogle(BuildContext context,bool isFromLogin) async {
    try {

      state = true;
      final user = await _authRepository.signInWithGoogle(isFromLogin).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Google sign-in timed out');
        },
      );

      user.fold(
        (l) {
          debugPrint('Error path triggered: ${l.message}');
          showSnackBar(context, l.message);
        },
        (userModel) {
          debugPrint('Success path triggered: $userModel');
          _ref.read(userProvider.notifier).update((state) => userModel);
        },
      );
    } catch (e, st) {
      state = false;
      debugPrint('Error in signInWithGoogle: $e');
      debugPrintStack(stackTrace: st);
      showSnackBar(context, 'Unexpected error occurred');
    } finally {
      debugPrint('Finally: setting loader to false');
      state = false;
    }
  }

  Future<void> signInAsGuest(BuildContext context) async {
    try {
      debugPrint('START: signInAsGuest');
      state = true;

      final user = await _authRepository.signInAsGuest().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Guest sign-in timed out');
        },
      );

      user.fold(
        (l) {
          debugPrint('Error path triggered: ${l.message}');
          showSnackBar(context, l.message);
        },
        (userModel) {
          debugPrint('Success path triggered: $userModel');
          _ref.read(userProvider.notifier).update((state) => userModel);
        },
      );
    } catch (e, st) {
      state = false;
      debugPrint('Error in signInAsGuest: $e');
      debugPrintStack(stackTrace: st);
      showSnackBar(context, 'Unexpected error occurred');
    } finally {
      debugPrint('Finally: setting loader to false');
      state = false;
    }
  }

  Stream<Either<Failure, UserModel>> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }

  void logOut() async {
    _authRepository.logOut();
  }
}
