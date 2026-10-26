
import 'package:flutter/material.dart';

import 'router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'House Price Prediction',
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
