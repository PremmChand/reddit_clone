import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reddit_clone/core/common/loader.dart';
import 'package:reddit_clone/features/auth/controller/auth_controller.dart';
import 'package:reddit_clone/router.dart';
import 'package:reddit_clone/theme/pallete.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:routemaster/routemaster.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _getUserData(currentUser);
    } else {
      _isLoading = false; // no user → stop loading
    }
  }

  Future<void> _getUserData(User user) async {
    final result = await ref.read(authControllerProvider.notifier).getUserData(user.uid).first;
    result.fold(
      (failure) {
        debugPrint("Error: ${failure.message}");
        _isLoading = false;
        setState(() {});
      },
      (userModel) {
        ref.read(userProvider.notifier).state = userModel;
        _isLoading = false;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = ref.watch(authStateChangeProvider).value;
    final userModel = ref.watch(userProvider);

    if (_isLoading) {
      return const Loader();
    }

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Reddit Tutorial',
      theme: ref.watch(themeNotifierProvider),
      routerDelegate: RoutemasterDelegate(
        routesBuilder: (_) {
          if (firebaseUser != null && userModel != null) {
            return loggedInRoute;
          }
          return loggedOutRoute;
        },
      ),
      routeInformationParser: const RoutemasterParser(),
    );
  }
}
