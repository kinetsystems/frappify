import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frappify/desk/desk.dart';
import 'package:frappify/login/login.dart';
import 'package:frappify/onboarding/view/onboarding_page.dart';
import 'package:frappify/splash/splash.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final size = MediaQuery.of(context).size;

    return BlocListener<SplashBloc, SplashState>(
      listener: (context, state) {
        if (state.navigationTarget != null) {
          switch (state.navigationTarget) {
            case NavigationTarget.onboardingPage:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const OnboardingPage()),
              );
            case NavigationTarget.loginPage:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const LoginPage()),
              );
            case NavigationTarget.deskPage:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const DeskPage()),
              );
            case null:
              break;
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.primary,
        body: RepaintBoundary(
          child: Stack(
            children: [
              Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Frappify',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width * 0.05,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'V0.0.1',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SpinKitWave(color: Colors.white, size: 30),
                    const SizedBox(height: 30),
                    Text(
                      'Powered By Kinet Systems',
                      style: TextStyle(
                        fontSize: size.width * 0.03,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
