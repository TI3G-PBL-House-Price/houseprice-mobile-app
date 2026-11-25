
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'main_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/home/home_page.dart';
import '../features/estimation/estimation_page.dart';
import '../features/mortgage/mortgage_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',

  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(
          navigationShell: navigationShell,
        );
      },

      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/estimation',
              builder: (context, state) => const EstimationPage(),
            ),
          ],
        ),

        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/mortgage',
              builder: (context, state) => const MortgagePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
