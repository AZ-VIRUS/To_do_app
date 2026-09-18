import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import 'auth/login_screen.dart';
import 'home/home_screen.dart';

/// Root gate of the app. Listens directly to Firebase's persistent auth
/// state stream and redirects unauthenticated users to [LoginScreen],
/// keeping every other screen "protected" behind this single widget.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          // Not signed in (or just signed out) -> clear old todo state
          // and show the login flow. Deferred to avoid notifying
          // listeners while this widget is still building.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<TodoProvider>().clear();
          });
          return const LoginScreen();
        }

        return HomeScreen(user: user);
      },
    );
  }
}
