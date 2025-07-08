import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frappe_client/frappe_client.dart';
import 'package:frappe_dart/src/models/apps_response/message.dart';
import 'package:frappify/apps/apps.dart';
import 'package:frappify/desk/desk.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AppsView extends StatelessWidget {
  const AppsView({super.key});

  @override
  Widget build(BuildContext context) {
    final frappe = context.read<FrappeClient>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ShadCard(
              child: SizedBox(
                width: 300,
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Section
                    _buildHeader(context),
                    const SizedBox(height: AppSpacing.xlg),

                    // Apps Grid Section
                    BlocBuilder<AppsBloc, AppsState>(
                      builder: (context, state) {
                        if (state.apps == null) {
                          return _buildLoadingState();
                        }

                        if (state.apps!.isEmpty) {
                          return _buildEmptyState();
                        }

                        return _buildAppsGrid(context, state, frappe);
                      },
                    ),

                    // Logout Button
                    const SizedBox(height: AppSpacing.lg),
                    _buildLogoutButton(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select an app to continue',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.lg),
          Text('Loading your apps...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.apps_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'No apps available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Contact your administrator to get access to apps',
            style: TextStyle(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppsGrid(
    BuildContext context,
    AppsState state,
    FrappeClient frappe,
  ) {
    return Center(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
        ),
        itemCount: state.apps?.length ?? 0,
        itemBuilder: (context, index) {
          final app = state.apps![index];
          return _buildAppCard(context, app, frappe);
        },
      ),
    );
  }

  Widget _buildAppCard(BuildContext context, Message app, FrappeClient frappe) {
    final theme = Theme.of(context);

    // Handle logo URL construction
    String? logoUrl;
    if (app.logo != null && app.logo.toString().isNotEmpty) {
      logoUrl = '${frappe.baseUrl}${app.logo}';
    }

    return InkWell(
      onTap: () {
        final name = app.route!.split('/').last;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DeskPage(workspace: name),
          ),
        );
            },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xs),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: logoUrl != null
                    ? Image.network(
                        logoUrl,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.apps,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 1.5,
                            ),
                          );
                        },
                      )
                    : Icon(
                        Icons.apps,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
              ),
            ),

            const SizedBox(height: AppSpacing.xxs),

            // App Title
            Text(
              app.title?.toString() ?? 'Untitled',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: ShadButton.outline(
        onPressed: () {
          // TODO: Implement logout functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logout functionality coming soon'),
            ),
          );
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.logout, size: 16),
            SizedBox(width: AppSpacing.xs),
            Text('Logout'),
          ],
        ),
      ),
    );
  }
}
