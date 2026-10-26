
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
  ],
);
