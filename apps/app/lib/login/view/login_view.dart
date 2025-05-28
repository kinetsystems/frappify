import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frappify/app_config/app_config.dart';
import 'package:frappify/desk/desk.dart';
import 'package:frappify/login/login.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == LoginStatus.success) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DeskPage()),
          );
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: 300,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Login to your account',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ShadInputFormField(
                              leading: Icon(
                                HugeIcons.strokeRoundedUser,
                                color: ShadTheme.of(
                                  context,
                                ).colorScheme.mutedForeground,
                              ),
                              label: const Text('Username'),
                              placeholder: const Text('john.doe@gmail.com'),
                              onChanged: (value) => context
                                  .read<LoginBloc>()
                                  .add(UsernameChangedEvent(value)),
                            ),
                            const SizedBox(height: 10),
                            ShadInputFormField(
                              leading: Icon(
                                HugeIcons.strokeRoundedPasswordValidation,
                                color: ShadTheme.of(
                                  context,
                                ).colorScheme.mutedForeground,
                              ),
                              label: const Text('Password'),
                              placeholder: const Text('••••••••'),
                              obscureText: !context
                                  .watch<LoginBloc>()
                                  .state
                                  .showPassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (context.read<LoginBloc>().state.isValid) {
                                  context.read<LoginBloc>().add(
                                    const LoginSubmittedEvent(),
                                  );
                                }
                              },
                              onChanged: (value) => context
                                  .read<LoginBloc>()
                                  .add(PasswordChangedEvent(value)),
                              trailing: SizedBox(
                                height: 20,
                                child: IconButton(
                                  padding: EdgeInsets.zero,

                                  onPressed: () =>
                                      context.read<LoginBloc>().add(
                                        const TogglePasswordVisibilityEvent(),
                                      ),
                                  icon: Icon(
                                    context.read<LoginBloc>().state.showPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: ShadTheme.of(
                                      context,
                                    ).colorScheme.mutedForeground,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            BlocBuilder<LoginBloc, LoginState>(
                              builder: (context, state) {
                                return ShadButton(
                                  width: 400,
                                  onPressed:
                                      context.read<LoginBloc>().state.isValid
                                      ? () => context.read<LoginBloc>().add(
                                          const LoginSubmittedEvent(),
                                        )
                                      : null,
                                  enabled: context
                                      .read<LoginBloc>()
                                      .state
                                      .isValid,
                                  child: (state.status == LoginStatus.loading)
                                      ? const SizedBox(
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                          ),
                                        )
                                      : (state.status == LoginStatus.success)
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )
                                      : (state.status == LoginStatus.failure)
                                      ? const Text('Invalid Login Credentials')
                                      : const Text('Login'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 10,
              right: 10,
              child: ShadButton.outline(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return const AppConfigPage();
                      },
                    ),
                  );
                },
                child: Icon(
                  size: 25,
                  color: ShadTheme.of(context).colorScheme.foreground,
                  HugeIcons.strokeRoundedSettings02,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
