import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frappify/app_config/bloc/app_config_bloc.dart';
import 'package:frappify/login/view/login_page.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppConfigView extends StatefulWidget {
  const AppConfigView({super.key});

  @override
  State<AppConfigView> createState() => _AppConfigViewState();
}

class _AppConfigViewState extends State<AppConfigView> {
  late SecureStorage secureStorage;
  final ShadTextEditingController hostaddress = ShadTextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    secureStorage = const SecureStorage();
    _getHostAddress();
  }

  Future<void> _getHostAddress() async {
    hostaddress.text = await secureStorage.read(key: 'host_address') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 10,
            child: ShadButton.outline(
              child: Icon(
                size: 20,
                color: theme.colorScheme.foreground,
                Icons.arrow_back,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return const LoginPage();
                    },
                  ),
                );
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text(
                        'App Config',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 50),
                      SizedBox(
                        width: 400,
                        child: ShadInputFormField(
                          controller: hostaddress,
                          label: Text(
                            'Host Address',
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          placeholder: Text(
                            'Add Host Address',
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Host Address Required';
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
                              return 'Enter Valid URL (e.g., http://example.com, https://example.com, http://10.0.0.2, http://[2001:db8::1], https://localhost, or https://localhost:8000)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      ShadButton.outline(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            context.read<AppConfigBloc>().add(
                              SubmitHostAddressEvent(
                                hostAddress: hostaddress.text,
                              ),
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(color: theme.colorScheme.foreground),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
