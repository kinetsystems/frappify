import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:frappify/l10n/l10n.dart';
import 'package:frappify/login/login.dart';
import 'package:frappify/onboarding/onboarding.dart';
import 'package:frappify/onboarding/widgets/item_language.dart';
import 'package:frappify/onboarding/widgets/item_theme.dart';
import 'package:frappify/settings/settings.dart';
import 'package:frappify/utils/utils.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final ShadTextEditingController hostaddress = ShadTextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late OnboardingBloc onboardingBloc;

  @override
  void initState() {
    super.initState();
    onboardingBloc = BlocProvider.of<OnboardingBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.isLoading) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) {
              return Center(
                child: SpinKitWave(
                  color: ShadTheme.of(context).colorScheme.primary,
                ),
              );
            },
          );
        } else {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        }
        if (state.onboardingCompleted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const LoginPage()),
          );
        }
      },
      child: IntroductionScreen(
        pages: [
          //Build language selection onboarding page
          _buildLanguageOnboardingPage(),

          //Build theme selection onboarding page
          _buildThemeOnboardingPage(),

          _buildOnboardingPage(
            title: 'Page 1',
            body: 'Page 1 Description',
            icon: Icons.ac_unit,
          ),
          _buildOnboardingPage(
            title: 'Page 2',
            body: 'Page 2 Description',
            icon: Icons.access_alarm,
          ),
          _buildOnboardingPage(
            title: 'Page 3',
            body: 'Page 3 Description',
            icon: Icons.access_time,
          ),
          PageViewModel(
            title: 'Host Name',
            image: Icon(
              HugeIcons.strokeRoundedConnect,
              color: theme.colorScheme.primary,
              size: 50,
            ),
            bodyWidget: _buildHostAddressForm(context),
          ),
        ],
        onDone: () {
          if (_formKey.currentState?.validate() ?? false) {
            onboardingBloc.add(
              CompleteOnboardingEvent(hostAddress: hostaddress.text),
            );
          } else {
            // Error toast is handled within the validator now
          }
        },
        showSkipButton: true,
        skip: const Text('Skip'),
        next: const Icon(Icons.arrow_forward),
        done: const Text('Done', style: TextStyle(fontWeight: FontWeight.w600)),
        dotsDecorator: DotsDecorator(activeColor: theme.colorScheme.primary),
      ),
    );
  }

  Widget _buildHostAddressForm(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(
            width: 400,
            child: ShadInputFormField(
              controller: hostaddress,
              label: Text(
                'Host Address',
                style: TextStyle(color: theme.colorScheme.foreground),
              ),
              placeholder: Text(
                'Add Host Address',
                style: TextStyle(color: theme.colorScheme.mutedForeground),
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return 'Host Address is Required'; // Return error message
                }
                final regex = RegExp(
                  r'^(https?:\/\/)'
                  '('
                  r'(([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6})|'
                  r'(\d{1,3}\.){3}\d{1,3}|'
                  r'\[([a-fA-F0-9:]+)\]|'
                  'localhost|'
                  '[a-zA-Z0-9-]+'
                  ')'
                  r'(:\d+)?(\/[^\s]*)?$',
                );

                if (!regex.hasMatch(value)) {
                  return 'Enter Valid Url (e.g., http://example.com, https://example.com, http://10.0.0.2, http://[2001:db8::1], https://localhost, or https://localhost:8000)';
                }

                return null; // Return null when valid
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  PageViewModel _buildOnboardingPage({
    required String title,
    required String body,
    required IconData icon,
  }) {
    final theme = ShadTheme.of(context);
    return PageViewModel(
      title: title,
      body: body,
      image: Center(
        child: Icon(icon, size: 80, color: theme.colorScheme.primary),
      ),
    );
  }

  PageViewModel _buildLanguageOnboardingPage() {
    final theme = ShadTheme.of(context);
    return PageViewModel(
      //title: 'Select Language',
      decoration: const PageDecoration(titlePadding: EdgeInsets.zero),
      titleWidget: Column(
        children: [
          const Text(
            'Select Language',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(
            'Language Preference',
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.foreground.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      bodyWidget: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ItemLanguage(
            selectedLan: Localizations.localeOf(context),
            locale: context.read<OnboardingBloc>().lang.elementAt(index),
            onTap: () {
              context.read<SettingsBloc>().add(
                LocaleChangedEvent(
                  locale: context.read<OnboardingBloc>().lang.elementAt(index),
                ),
              );
            },
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 0);
        },
        itemCount: AppLocalizations.supportedLocales.length,
      ),
      image: CircleAvatar(
        backgroundColor: ShadColorScheme.fromName(
          'blue',
        ).primary.withValues(alpha: 0.2),
        radius: 48,
        child: Center(
          child: Icon(
            Icons.language,
            size: 58,
            color: ShadColorScheme.fromName('blue').primary,
          ),
        ),
      ),
    );
  }

  PageViewModel _buildThemeOnboardingPage() {
    final theme = ShadTheme.of(context);
    return PageViewModel(
      //title: 'Select Language',
      decoration: const PageDecoration(titlePadding: EdgeInsets.zero),
      titleWidget: Column(
        children: [
          const Text(
            'Select Theme',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Text(
            'Theme Preference',
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.foreground.withValues(alpha: 0.5),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      bodyWidget: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 12, top: 20),
            child: Text(
              'Theme Preference',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
            ),
          ),
          const SizedBox(height: 14),
          ...['System', 'Light', 'Dark'].map((String theme) {
            return ItemTheme(
              theme: theme,
              onTap: () {
                context.read<SettingsBloc>().add(
                  ThemeChangedEvent(themeMode: mapStringToThemeMode(theme)),
                );
              },
            );
          }),
        ],
      ),

      image: CircleAvatar(
        backgroundColor: ShadColorScheme.fromName(
          'orange',
        ).primary.withValues(alpha: 0.3),
        radius: 48,
        child: Center(
          child: Icon(
            Icons.palette_outlined,
            size: 58,
            color: ShadColorScheme.fromName('orange').primary,
          ),
        ),
      ),
    );
  }
}
