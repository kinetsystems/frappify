import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frappify/desk/desk.dart';
import 'package:frappify/settings/settings.dart';
import 'package:frappify/utils/utils.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class DeskView extends StatefulWidget {
  const DeskView({super.key});

  @override
  State<DeskView> createState() => _DeskViewState();
}

class _DeskViewState extends State<DeskView> {
  final notificationsPopoverController = ShadPopoverController();
  final helpPopoverController = ShadPopoverController();
  final profilePopoverController = ShadPopoverController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    notificationsPopoverController.dispose();
    helpPopoverController.dispose();
    profilePopoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final responsive = ResponsiveBreakpoints.of(context);
    return BlocBuilder<DeskBloc, DeskState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: theme.colorScheme.background,
            title: Padding(
              padding: const EdgeInsets.all(12),
              child: SvgPicture.asset(
                'assets/images/frappe.svg',
                colorFilter: ColorFilter.mode(
                  theme.colorScheme.primary,
                  BlendMode.srcIn,
                ),
                width: 30,
                height: 80,
              ),
            ),
            actions: [
              // Notifications
              ShadPopover(
                controller: notificationsPopoverController,
                popover: (context) => SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Notifications', style: theme.textTheme.h4),
                      ),
                      const Divider(),
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: theme.colorScheme.primary
                                  .withOpacity(0.1),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            title: Text('Notification ${index + 1}'),
                            subtitle: Text('This is notification ${index + 1}'),
                            trailing: Text(
                              '2m ago',
                              style: theme.textTheme.small.copyWith(
                                color: theme.colorScheme.foreground,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                child: ShadButton.ghost(
                  onPressed: notificationsPopoverController.toggle,
                  hoverBackgroundColor: Colors.transparent,
                  child: Badge(
                    label: const Text('3'),
                    child: Icon(
                      Icons.notifications_outlined,
                      color: theme.colorScheme.foreground,
                    ),
                  ),
                ),
              ),

              // horizontal divider
              const SizedBox(width: 8),
              Divider(height: 24, color: theme.colorScheme.foreground),
              const SizedBox(width: 8),
              if (responsive.isDesktop)
                ShadPopover(
                  controller: helpPopoverController,
                  popover: (context) => SizedBox(
                    width: 170,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ShadButton.ghost(
                          child: Text(
                            'Documentation',
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          onPressed: () {},
                        ),
                        ShadButton.ghost(
                          child: Text(
                            'User Forum',
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          onPressed: () {},
                        ),
                        ShadButton.ghost(
                          child: Text(
                            'Frappe School',
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          onPressed: () {},
                        ),
                        ShadButton.ghost(
                          child: Text(
                            'Report an Issue',
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          onPressed: () {},
                        ),
                        ShadButton.ghost(
                          child: Text(
                            'About',
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          onPressed: () {},
                        ),
                        ShadButton.ghost(
                          child: Text(
                            'Keyboard Shortcuts',
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          onPressed: () {},
                        ),
                        ShadButton.ghost(
                          child: Text(
                            'Frappe Support',
                            style: TextStyle(
                              color: theme.colorScheme.foreground,
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  child: ShadButton.ghost(
                    onPressed: helpPopoverController.toggle,
                    hoverBackgroundColor: Colors.transparent,
                    child: Row(
                      children: [
                        Text('Help', style: theme.textTheme.small),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_downward,
                          color: theme.colorScheme.foreground,
                        ),
                      ],
                    ),
                  ),
                ),
              // Profile
              ShadPopover(
                controller: profilePopoverController,
                popover: (context) => SizedBox(
                  width: 200,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShadButton.ghost(
                        onPressed: () {},
                        child: Text(
                          'My Profile',
                          style: TextStyle(color: theme.colorScheme.foreground),
                        ),
                      ),
                      ShadButton.ghost(
                        onPressed: () {},
                        child: Text(
                          'My Settings',
                          style: TextStyle(color: theme.colorScheme.foreground),
                        ),
                      ),
                      ShadButton.ghost(
                        onPressed: () {},
                        child: Text(
                          'Session Defaults',
                          style: TextStyle(color: theme.colorScheme.foreground),
                        ),
                      ),
                      ShadButton.ghost(
                        onPressed: () {},
                        child: Text(
                          'Reload',
                          style: TextStyle(color: theme.colorScheme.foreground),
                        ),
                      ),
                      ShadButton.ghost(
                        onPressed: () {},
                        child: Text(
                          'Apps',
                          style: TextStyle(color: theme.colorScheme.foreground),
                        ),
                      ),
                      ShadButton.ghost(
                        onPressed: () {},
                        child: Text(
                          'Toggle Full Width',
                          style: TextStyle(color: theme.colorScheme.foreground),
                        ),
                      ),
                      ShadButton.ghost(
                        onPressed: () {
                          profilePopoverController.toggle();
                          showShadDialog(
                            context: context,
                            builder: (context) => ShadDialog(
                              title: const Text('Switch Theme'),
                              child: Row(
                                children: [
                                  Card(
                                    child: InkWell(
                                      onTap: () {
                                        context.read<SettingsBloc>().add(
                                          const ThemeChangedEvent(
                                            themeMode: ThemeMode.light,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Column(
                                        children: [Text('Frappe Light')],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: InkWell(
                                      onTap: () {
                                        context.read<SettingsBloc>().add(
                                          const ThemeChangedEvent(
                                            themeMode: ThemeMode.dark,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Column(
                                        children: [Text('Timeless Night')],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    child: InkWell(
                                      onTap: () {
                                        context.read<SettingsBloc>().add(
                                          const ThemeChangedEvent(
                                            themeMode: ThemeMode.system,
                                          ),
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: const Column(
                                        children: [Text('Automatic')],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Toggle Theme',
                          style: TextStyle(color: theme.colorScheme.foreground),
                        ),
                      ),
                      const Divider(),
                      ShadButton.ghost(
                        onPressed: () {
                          context.read<DeskBloc>().add(
                            LogoutEvent(context: context),
                          );
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(color: theme.colorScheme.foreground),
                        ),
                      ),
                    ],
                  ),
                ),
                child: ShadButton.ghost(
                  onPressed: profilePopoverController.toggle,
                  hoverBackgroundColor: Colors.transparent,
                  child: ShadAvatar(
                    'https://app.requestly.io/delay/2000/avatars.githubusercontent.com/u/1d24599?v=4',
                    placeholder: Text(getInitials(state.username ?? '')),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
          drawer: !responsive.isDesktop
              ? NavigationDrawer(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                    if (state.workspaces != null) {
                      context.read<DeskBloc>().add(
                        LoadWorkspaceEvent(
                          workspaceId: state.workspaces![index].name!,
                        ),
                      );
                    }
                    Navigator.pop(context);
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
                      child: Text('Menu', style: theme.textTheme.h4),
                    ),
                    if (state.workspaces != null)
                      ...state.workspaces!.map(
                        (workspace) => NavigationDrawerDestination(
                          icon: const Icon(Icons.dashboard_outlined),
                          label: Text(workspace.label!),
                        ),
                      ),
                  ],
                )
              : null,
          body: Row(
            children: [
              if (responsive.isDesktop)
                Container(
                  width: 240,
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: theme.colorScheme.border),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Workspace', style: theme.textTheme.h4),
                      ),
                      if (state.workspaces != null)
                        ...state.workspaces!.map(
                          (workspace) => ShadButton.ghost(
                            onPressed: () {
                              context.read<DeskBloc>().add(
                                LoadWorkspaceEvent(
                                  workspaceId: workspace.name!,
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(
                                  Icons.dashboard_outlined,
                                  size: 16,
                                  color: theme.colorScheme.foreground,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  workspace.label!,
                                  style: theme.textTheme.small,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (state.currentWorkspace != null) ...[
                        Text(
                          state.currentWorkspace!,
                          style: theme.textTheme.h2,
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (state.workspace?.shortcuts?.items != null)
                        if (state.workspace?.shortcuts?.items?.isNotEmpty ==
                            true) ...[
                          Text('Your Shortcuts', style: theme.textTheme.h3),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: (state.workspace?.shortcuts?.items ?? [])
                                .map(
                                  (shortcut) => ShadCard(
                                    child: InkWell(
                                      onTap: () {},
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.star_outline,
                                              color: theme.colorScheme.primary,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              shortcut.label!,
                                              style: theme.textTheme.small,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      if (state.workspace?.cards?.items != null)
                        if (state.workspace?.cards?.items?.isNotEmpty ==
                            true) ...[
                          const SizedBox(height: 32),
                          Text('Reports & Masters', style: theme.textTheme.h3),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: (state.workspace?.cards?.items ?? [])
                                .map(
                                  (card) => ShadCard(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            card.label!,
                                            style: theme.textTheme.h4,
                                          ),
                                          const SizedBox(height: 12),
                                          ...(card.links ?? []).map(
                                            (link) => InkWell(
                                              onTap: () {},
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 8,
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.link,
                                                      size: 16,
                                                      color: theme
                                                          .colorScheme
                                                          .mutedForeground,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      link.label!,
                                                      style: theme
                                                          .textTheme
                                                          .small
                                                          .copyWith(
                                                            color: theme
                                                                .colorScheme
                                                                .mutedForeground,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
