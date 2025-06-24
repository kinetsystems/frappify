import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappify/apps/apps.dart';
import 'package:frappify/desk/desk.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppsView extends StatelessWidget {
  const AppsView({super.key});

  @override
  Widget build(BuildContext context) {
    final frappe = context.read<FrappeClient>();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ShadCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Select an app to continue'),
                const SizedBox(height: 16),
                BlocBuilder<AppsBloc, AppsState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: 300,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: state.apps?.length ?? 0,
                        itemBuilder: (context, index) => InkWell(
                          onTap: () {
                            final name = state.apps?[index].route!
                                .split('/')
                                .last;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DeskPage(
                                  workspace: name,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Image.network(
                                '${frappe.baseUrl}${state.apps?[index].logo ?? ''}',
                                width: 50,
                                height: 50,
                              ),
                              Text(state.apps?[index].title ?? ''),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: Row(
                    children: [Icon(Icons.logout), Text('Logout')],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
