import 'package:car_service/customizations/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '/helper/extension/context_extension.dart';
import '/services/dynamics/dynamics_service.dart';
import '../../helper/local_keys.g.dart';
import '../../view_models/splash_view_model/splash_view_model.dart';

class SplashView extends StatefulWidget {
  static const routeName = '/';
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      SplashViewModel().initiateStartingSequence(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Image.asset(
          'assets/images/jusmoto.png',
          width: 120, // Reduced to match native splash scale
          fit: BoxFit.contain,
        )
        .animate()
        .fadeIn(duration: const Duration(milliseconds: 300)),
      ),
    );
  }
}
