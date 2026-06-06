import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers/theme_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/chat_screen.dart';
import 'ui/screens/profile_screen.dart';

final _routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/chat/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ChatScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
});

class ChatYuiApp extends ConsumerWidget {
  const ChatYuiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final router = ref.watch(_routerProvider);

    return MaterialApp.router(
      title: 'Rem',
      debugShowCheckedModeBanner: false,
      theme: themeState.themeData,
      routerConfig: router,
    );
  }
}
